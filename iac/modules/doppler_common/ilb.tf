# This creates the internal application load balancer for doppler

resource "aws_alb" "internal" {
  name = "${local.ns}-ilb"

  # launch lbs in public or private subnets based on "internal" variable
  internal = true
  subnets = split(
    ",",
    var.private_subnets,
  )
  security_groups = [aws_security_group.nsg_lb.id]
  tags            = var.tags

  # enable access logs in order to get support from aws
  access_logs {
    enabled = true
    bucket  = aws_s3_bucket.ilb_access_logs.bucket
  }
}

resource "aws_alb_target_group" "internal" {
  name                 = "${local.ns}-ilb"
  port                 = var.lb_port
  protocol             = var.lb_protocol
  vpc_id               = var.vpc
  target_type          = "ip"
  deregistration_delay = var.deregistration_delay

  health_check {
    path                = var.health_check
    matcher             = var.health_check_matcher
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }

  tags = var.tags

  depends_on = [aws_alb.internal]
}

data "aws_elb_service_account" "internal" {
}

# bucket for storing ALB access logs
resource "aws_s3_bucket" "ilb_access_logs" {
  bucket        = "${local.ns}-ilb-access-logs"
  tags          = var.tags
  force_destroy = true
}

resource "aws_s3_bucket_acl" "ilb_access_logs" {
  bucket = aws_s3_bucket.ilb_access_logs.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ilb_access_logs" {
  bucket = aws_s3_bucket.ilb_access_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "ilb_lifecycle" {
  bucket = aws_s3_bucket.ilb_access_logs.id

  rule {
    id     = "cleanup"
    prefix = "ilb-cleanup"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }

  rule {
    status = var.enable_data_archival ? "Enabled" : "Disabled"
    id     = "move-to-glacier-after-few-weeks"
    prefix = "ilb-glacier"
    transition {
      storage_class = "GLACIER"
      days          = var.data_transition_duration_in_days
    }
  }
}

# give load balancing service access to the bucket
resource "aws_s3_bucket_policy" "ilb_access_logs" {
  bucket = aws_s3_bucket.ilb_access_logs.id

  policy = <<POLICY
{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.ilb_access_logs.arn}",
        "${aws_s3_bucket.ilb_access_logs.arn}/*"
      ],
      "Principal": {
        "AWS": [ "${data.aws_elb_service_account.internal.arn}" ]
      }
    }
  ]
}
POLICY
}
