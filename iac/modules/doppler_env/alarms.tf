resource "aws_sns_topic" "alert_topic" {
  name = "${var.app}-alerts-${var.environment_us_east_1}"
}

# us-east-1 alarms

# ALB Alarms
resource "aws_cloudwatch_metric_alarm" "too_many_requests_us_east_1" {
  depends_on          = [module.us_east_1.lb_arn_suffix]
  alarm_name          = "${local.nsuseast1}-too-many-requests"
  alarm_description   = "Request count has crossed 10k per second"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "HTTPCode_Target_2XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "15600000"
  tags                = var.tags
  dimensions = {
    LoadBalancer = module.us_east_1.lb_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alert_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "too_many_5xx_response_us_east_1" {
  depends_on          = [module.us_east_1.lb_arn_suffix]
  alarm_name          = "${local.nsuseast1}-too-many-5xx-response"
  alarm_description   = "Service is returning too many 5xx response"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  threshold           = "0.04" # 4%
  datapoints_to_alarm = "1"
  tags                = var.tags

  metric_query {
    id          = "m1"
    return_data = false

    metric {
      dimensions = {
        "LoadBalancer" = module.us_east_1.lb_arn_suffix
      }
      metric_name = "HTTPCode_Target_5XX_Count"
      namespace   = "AWS/ApplicationELB"
      period      = 300
      stat        = "Sum"
    }
  }
  metric_query {
    id          = "m3"
    return_data = false

    metric {
      dimensions = {
        "LoadBalancer" = module.us_east_1.lb_arn_suffix
      }
      metric_name = "RequestCount"
      namespace   = "AWS/ApplicationELB"
      period      = 300
      stat        = "Sum"
    }
  }
  metric_query {
    expression  = "m1/m3"
    id          = "e1"
    label       = "5xx ratio"
    return_data = true
  }

  alarm_actions = [aws_sns_topic.alert_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "too_many_4xx_response_us_east_1" {
  depends_on          = [module.us_east_1.lb_arn_suffix]
  alarm_name          = "${local.nsuseast1}-too-many-4xx-response"
  alarm_description   = "Service is returning too many 4xx response"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  threshold           = "0.01" # 1%
  datapoints_to_alarm = "1"
  tags                = var.tags

  metric_query {
    id          = "m1"
    return_data = false

    metric {
      dimensions = {
        "LoadBalancer" = module.us_east_1.lb_arn_suffix
      }
      metric_name = "HTTPCode_Target_4XX_Count"
      namespace   = "AWS/ApplicationELB"
      period      = 300
      stat        = "Sum"
    }
  }
  metric_query {
    id          = "m2"
    return_data = false

    metric {
      dimensions = {
        "LoadBalancer" = module.us_east_1.lb_arn_suffix
      }
      metric_name = "RequestCount"
      namespace   = "AWS/ApplicationELB"
      period      = 300
      stat        = "Sum"
    }
  }
  metric_query {
    expression  = "m1/m2"
    id          = "e1"
    label       = "4xx ratio"
    return_data = true
  }

  alarm_actions = [aws_sns_topic.alert_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "too_many_unhealthy_hosts_us_east_1" {
  depends_on          = [module.us_east_1.lb_arn_suffix]
  alarm_name          = "${local.nsuseast1}-too-many-unhealthy-hosts"
  alarm_description   = "Too many hosts are reported as unhealthy"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  threshold           = "0.04" # 4%
  datapoints_to_alarm = "1"
  tags                = var.tags

  metric_query {
    id          = "m1"
    return_data = false

    metric {
      dimensions = {
        "LoadBalancer" = module.us_east_1.lb_arn_suffix
        "TargetGroup"  = module.us_east_1.lb_tg_arn_suffix
      }
      metric_name = "UnHealthyHostCount"
      namespace   = "AWS/ApplicationELB"
      period      = 300
      stat        = "Sum"
    }
  }
  metric_query {
    id          = "m2"
    return_data = false

    metric {
      dimensions = {
        "LoadBalancer" = module.us_east_1.lb_arn_suffix
        "TargetGroup"  = module.us_east_1.lb_tg_arn_suffix
      }
      metric_name = "HealthyHostCount"
      namespace   = "AWS/ApplicationELB"
      period      = 300
      stat        = "Sum"
    }
  }
  metric_query {
    expression  = "m1/m2"
    id          = "e1"
    label       = "Unhealthy-Healthy ratio"
    return_data = true
  }

  alarm_actions = [aws_sns_topic.alert_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "high_response_time_us_east_1" {
  depends_on          = [module.us_east_1.lb_arn_suffix]
  alarm_name          = "${local.nsuseast1}-high-response-time"
  alarm_description   = "Service response time is high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  threshold           = "1"
  tags                = var.tags
  dimensions = {
    LoadBalancer = module.us_east_1.lb_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alert_topic.arn]
}

# Fargate Containers Alarms
resource "aws_cloudwatch_metric_alarm" "high_running_task_count_us_east_1" {
  depends_on          = [module.us_east_1.ecs_cluster_name, module.us_east_1.ecs_service_name]
  alarm_name          = "${local.nsuseast1}-high-running-task-count"
  alarm_description   = "Number of running task is high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "RunningTaskCount"
  namespace           = "ECS/ContainerInsights"
  period              = "300"
  statistic           = "Average"
  threshold           = "128"
  tags                = var.tags
  dimensions = {
    ClusterName = module.us_east_1.ecs_cluster_name
    ServiceName = module.us_east_1.ecs_service_name
  }

  alarm_actions = [aws_sns_topic.alert_topic.arn]
}

# ECS Alarms
resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization_us_east_1" {
  depends_on          = [module.us_east_1.ecs_cluster_name, module.us_east_1.ecs_service_name]
  alarm_name          = "${local.nsuseast1}-high-cpu-utilization"
  alarm_description   = "CPU Utilization is high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "90"
  tags                = var.tags
  dimensions = {
    ClusterName = module.us_east_1.ecs_cluster_name
    ServiceName = module.us_east_1.ecs_service_name
  }

  alarm_actions = [aws_sns_topic.alert_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "high_memory_utilization_us_east_1" {
  depends_on          = [module.us_east_1.ecs_cluster_name, module.us_east_1.ecs_service_name]
  alarm_name          = "${local.nsuseast1}-high-memory-utilization"
  alarm_description   = "Memory utilization is high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "90"
  tags                = var.tags
  dimensions = {
    ClusterName = module.us_east_1.ecs_cluster_name
    ServiceName = module.us_east_1.ecs_service_name
  }

  alarm_actions = [aws_sns_topic.alert_topic.arn]
}


# us-west-2 alarms

# ALB Alarms
resource "aws_cloudwatch_metric_alarm" "too_many_requests_us_west_2" {
  depends_on          = [module.us_west_2.lb_arn_suffix]
  alarm_name          = "${local.nsuswest2}-too-many-requests"
  alarm_description   = "Request count has crossed 10k per second"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "HTTPCode_Target_2XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "15600000"
  tags                = var.tags
  dimensions = {
    LoadBalancer = module.us_west_2.lb_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alert_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "too_many_5xx_response_us_west_2" {
  depends_on          = [module.us_west_2.lb_arn_suffix]
  alarm_name          = "${local.nsuswest2}-too-many-5xx-response"
  alarm_description   = "Service is returning too many 5xx response"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  threshold           = "0.04"
  tags                = var.tags

  metric_query {
    id          = "m1"
    return_data = false

    metric {
      dimensions = {
        "LoadBalancer" = module.us_west_2.lb_arn_suffix
      }
      metric_name = "HTTPCode_Target_5XX_Count"
      namespace   = "AWS/ApplicationELB"
      period      = 300
      stat        = "Sum"
    }
  }
  metric_query {
    id          = "m3"
    return_data = false

    metric {
      dimensions = {
        "LoadBalancer" = module.us_west_2.lb_arn_suffix
      }
      metric_name = "RequestCount"
      namespace   = "AWS/ApplicationELB"
      period      = 300
      stat        = "Sum"
    }
  }
  metric_query {
    expression  = "m1/m3"
    id          = "e1"
    label       = "5xx ratio"
    return_data = true
  }

  alarm_actions = [aws_sns_topic.alert_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "too_many_4xx_response_us_west_2" {
  depends_on          = [module.us_west_2.lb_arn_suffix]
  alarm_name          = "${local.nsuswest2}-too-many-4xx-response"
  alarm_description   = "Service is returning too many 4xx response"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  threshold           = "0.01"
  datapoints_to_alarm = "1"
  tags                = var.tags

  metric_query {
    id          = "m1"
    return_data = false

    metric {
      dimensions = {
        "LoadBalancer" = module.us_west_2.lb_arn_suffix
      }
      metric_name = "HTTPCode_Target_4XX_Count"
      namespace   = "AWS/ApplicationELB"
      period      = 300
      stat        = "Sum"
    }
  }
  metric_query {
    id          = "m2"
    return_data = false

    metric {
      dimensions = {
        "LoadBalancer" = module.us_west_2.lb_arn_suffix
      }
      metric_name = "RequestCount"
      namespace   = "AWS/ApplicationELB"
      period      = 300
      stat        = "Sum"
    }
  }
  metric_query {
    expression  = "m1/m2"
    id          = "e1"
    label       = "4xx ratio"
    return_data = true
  }

  alarm_actions = [aws_sns_topic.alert_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "too_many_unhealthy_hosts_us_west_2" {
  depends_on          = [module.us_west_2.lb_arn_suffix]
  alarm_name          = "${local.nsuswest2}-too-many-unhealthy-hosts"
  alarm_description   = "Too many hosts are reported as unhealthy"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  threshold           = "0.04" # 4%
  datapoints_to_alarm = "1"
  tags                = var.tags

  metric_query {
    id          = "m1"
    return_data = false

    metric {
      dimensions = {
        "LoadBalancer" = module.us_west_2.lb_arn_suffix
        "TargetGroup"  = module.us_west_2.lb_tg_arn_suffix
      }
      metric_name = "UnHealthyHostCount"
      namespace   = "AWS/ApplicationELB"
      period      = 300
      stat        = "Sum"
    }
  }
  metric_query {
    id          = "m2"
    return_data = false

    metric {
      dimensions = {
        "LoadBalancer" = module.us_west_2.lb_arn_suffix
        "TargetGroup"  = module.us_west_2.lb_tg_arn_suffix
      }
      metric_name = "HealthyHostCount"
      namespace   = "AWS/ApplicationELB"
      period      = 300
      stat        = "Sum"
    }
  }
  metric_query {
    expression  = "m1/m2"
    id          = "e1"
    label       = "Unhealthy-Healthy ratio"
    return_data = true
  }

  alarm_actions = [aws_sns_topic.alert_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "high_response_time_us_west_2" {
  depends_on          = [module.us_west_2.lb_arn_suffix]
  alarm_name          = "${local.nsuswest2}-high-response-time"
  alarm_description   = "Service response time is high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  threshold           = "1"
  tags                = var.tags
  dimensions = {
    LoadBalancer = module.us_west_2.lb_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alert_topic.arn]
}

# Fargate Containers Alarms
resource "aws_cloudwatch_metric_alarm" "high_running_task_count_us_west_2" {
  depends_on          = [module.us_west_2.ecs_cluster_name, module.us_west_2.ecs_service_name]
  alarm_name          = "${local.nsuswest2}-high-running-task-count"
  alarm_description   = "Number of running task is high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "RunningTaskCount"
  namespace           = "ECS/ContainerInsights"
  period              = "300"
  statistic           = "Average"
  threshold           = "128"
  tags                = var.tags
  dimensions = {
    ClusterName = module.us_west_2.ecs_cluster_name
    ServiceName = module.us_west_2.ecs_service_name
  }

  alarm_actions = [aws_sns_topic.alert_topic.arn]
}

# ECS Alarms
resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization_us_west_2" {
  depends_on          = [module.us_west_2.ecs_cluster_name, module.us_west_2.ecs_service_name]
  alarm_name          = "${local.nsuswest2}-high-cpu-utilization"
  alarm_description   = "CPU Utilization is high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "90"
  tags                = var.tags
  dimensions = {
    ClusterName = module.us_west_2.ecs_cluster_name
    ServiceName = module.us_west_2.ecs_service_name
  }

  alarm_actions = [aws_sns_topic.alert_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "high_memory_utilization_us_west_2" {
  depends_on          = [module.us_west_2.ecs_cluster_name, module.us_west_2.ecs_service_name]
  alarm_name          = "${local.nsuswest2}-high-memory-utilization"
  alarm_description   = "Memory utilization is high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "90"
  tags                = var.tags
  dimensions = {
    ClusterName = module.us_west_2.ecs_cluster_name
    ServiceName = module.us_west_2.ecs_service_name
  }

  alarm_actions = [aws_sns_topic.alert_topic.arn]
}
