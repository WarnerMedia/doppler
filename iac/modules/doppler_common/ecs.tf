/**
 * Elastic Container Service (ecs)
 * This component is required to create the Fargate ECS service. It will create a Fargate cluster
 * based on the application name and enironment. It will create a "Task Definition", which is required
 * to run a Docker container, https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html.
 * Next it creates a ECS Service, https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html
 * It attaches the Load Balancer created in `lb.tf` and `ilb.tf` to the service, and sets up the networking required.
 * It also creates a role with the correct permissions. And lastly, ensures that logs are captured in CloudWatch.
 *
 * When building for the first time, it will install a "default backend", which is a simple web service that just
 * responds with a HTTP 200 OK. It's important to uncomment the lines noted below after you have successfully
 * migrated the real application containers to the task definition.
 */

resource "aws_ecs_cluster" "app" {
  name = local.ns
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = var.tags
}

# The default docker image to deploy with the infrastructure.
# Note that you can use the fargate CLI for application concerns
# like deploying actual application images and environment variables
# on top of the infrastructure provisioned by this template
# https://github.com/turnerlabs/fargate
# note that the source for the turner default backend image is here:
# https://github.com/turnerlabs/turner-defaultbackend
variable "default_backend_image" {
  default = "quay.io/turner/turner-defaultbackend:0.2.0"
}

resource "aws_ecs_task_definition" "app" {
  family                   = local.ns
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "2048"
  memory                   = "4096"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn

  # defined in role.tf
  task_role_arn = aws_iam_role.app_role.arn

  container_definitions = <<DEFINITION
[
  {
    "name": "${var.container_name}",
    "image": "${var.default_backend_image}",
    "essential": true,
    "dependsOn": [
      {
        "containerName": "kpl",
        "condition": "START"
      }
    ],    
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": ${var.container_port},
        "hostPort": ${var.container_port}
      }
    ],
    "environment": [
      {
        "name": "PORT",
        "value": "${var.container_port}"
      },
      {
        "name": "HEALTHCHECK",
        "value": "${var.health_check}"
      },
      {
        "name": "ENABLE_LOGGING",
        "value": "true"
      },
      {
        "name": "LOG_LEVEL",
        "value": "${var.log_level}"
      },
      {
        "name": "PRODUCT",
        "value": "${var.app}"
      },
      {
        "name": "ENVIRONMENT",
        "value": "${var.environment}"
      },
      {
        "name": "METRIC_PREFIX",
        "value": "${var.app}-${var.environment}"
      },
      {
        "name": "SOCKET_SERVER_PORT",
        "value": "${var.kpl_port}"
      },
      {
        "name": "DLQ_URL",
        "value": "${aws_sqs_queue.dlq.id}"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/fargate/service/${local.ns}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "ulimits": [
      {
        "name": "nofile",
        "softLimit": 1024000,
        "hardLimit": 1024000
      }
    ]
  },
  {
    "name": "kpl",
    "image": "public.ecr.aws/v6s5y4v7/kplserver:v0.2.20",
    "essential": true,
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": 3000,
        "hostPort": 3000
      }
    ],
    "environment": [
      {
        "name": "KINESIS_STREAM",
        "value": "${aws_kinesis_stream.main.name}"
      },
      {
        "name": "PORT",
        "value": "3000"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/fargate/service/${local.ns}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "ulimits": [
      {
        "name": "nofile",
        "softLimit": 1024000,
        "hardLimit": 1024000
      }
    ]
  },
  {
    "name": "cloudwatch-agent",
    "image": "public.ecr.aws/cloudwatch-agent/cloudwatch-agent:latest",
    "essential": false,
    "secrets": [
      {
        "name": "CW_CONFIG_CONTENT",
        "valueFrom": "${aws_ssm_parameter.cw_agent.name}"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/fargate/service/${local.ns}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }  
]
DEFINITION

  tags = var.tags
}

resource "aws_ecs_service" "app" {
  name            = local.ns
  cluster         = aws_ecs_cluster.app.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1

  network_configuration {
    security_groups = [aws_security_group.nsg_task.id]
    subnets         = split(",", var.private_subnets)
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.main.id
    container_name   = var.container_name
    container_port   = var.container_port
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.internal.id
    container_name   = var.container_name
    container_port   = var.container_port
  }

  tags                    = var.tags
  enable_ecs_managed_tags = true
  propagate_tags          = "SERVICE"

  # workaround for https://github.com/hashicorp/terraform/issues/12634
  depends_on = [aws_alb_listener.http]

  # [after initial apply] don't override changes made to task_definition
  # from outside of terraform (i.e.; fargate cli)
  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "${local.ns}-ecs"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "cw_agent_server_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ssm_readonly_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_cloudwatch_log_group" "logs" {
  name              = "/fargate/service/${local.ns}"
  retention_in_days = 14
  tags              = var.tags
}

resource "aws_ssm_parameter" "cw_agent" {
  description = "Cloudwatch agent config to configure statsd"
  name        = local.ns
  type        = "String"
  tags        = var.tags
  value       = <<EOF
{
  "metrics" : {
    "metrics_collected" : {
      "statsd" : {
        "service_address" : ":8125"
      }
    }
  }
}
EOF
}

