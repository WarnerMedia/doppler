# The SAML role to use for adding users to the ECR policy
variable "saml_role" {
}

# creates an application role that the container/task runs as
resource "aws_iam_role" "app_role" {
  name               = local.ns
  assume_role_policy = data.aws_iam_policy_document.app_role_assume_role_policy.json
  tags               = var.tags
}

# assigns the app policy
resource "aws_iam_role_policy" "app_policy" {
  name   = local.ns
  role   = aws_iam_role.app_role.id
  policy = data.aws_iam_policy_document.app_policy.json
}

data "aws_iam_policy_document" "app_policy" {

  # access to the data stream
  statement {
    actions = [
      "kinesis:*",
    ]
    resources = [aws_kinesis_stream.main.arn]
  }

  # use of kinesis encryption key
  statement {
    actions = [
      "kms:*",
    ]
    resources = [
      aws_kms_key.kinesis.arn
    ]
  }

  # access to the sqs sendmessage
  statement {
    actions = [
      "sqs:SendMessage",
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage"
    ]
    resources = [
      aws_sqs_queue.dlq.arn,
    ]
  }

  # to allow the writing of cw metric data
  statement {
    actions = [
      "cloudwatch:PutMetricData"
    ]
    resources = ["*"]
  }

  # to allow access to cw agent rule
  statement {
    actions = [
      "ssm:GetParameter"
    ]
    resources = ["*"]
  }
}

data "aws_caller_identity" "current" {
}

# allow role to be assumed by ecs and local saml users (for development)
data "aws_iam_policy_document" "app_role_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    principals {
      type = "AWS"

      identifiers = [
      ]
    }
  }
}
