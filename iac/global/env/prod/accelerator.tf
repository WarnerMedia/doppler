# Main GA Accelerator

resource "aws_globalaccelerator_accelerator" "doppler" {
  name            = "${var.app}-${var.environment}"
  ip_address_type = "IPV4"
  enabled         = true
  tags            = var.tags

  attributes {
    flow_logs_enabled   = true
    flow_logs_s3_bucket = aws_s3_bucket.ga_flow_logs.id
    flow_logs_s3_prefix = "flow-logs/"
  }
}

variable "ga_flow_logs_expiration_days" {
  default = "7"
}

# bucket for storing GA flow logs
resource "aws_s3_bucket" "ga_flow_logs" {
  bucket        = var.flow_logs_bucket_name
  tags          = var.tags
  force_destroy = true

  lifecycle_rule {
    id                                     = "cleanup"
    enabled                                = true
    abort_incomplete_multipart_upload_days = 1
    prefix                                 = ""

    expiration {
      days = var.ga_flow_logs_expiration_days
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
