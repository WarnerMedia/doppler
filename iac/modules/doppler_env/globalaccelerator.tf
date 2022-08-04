# Main GA Accelerator

resource "aws_globalaccelerator_accelerator" "doppler" {
  name            = "${var.app}-${var.common_environment}"
  ip_address_type = "IPV4"
  enabled         = true
  tags            = var.tags

  attributes {
    flow_logs_enabled   = false
    flow_logs_s3_bucket = aws_s3_bucket.ga_flow_logs.id
    flow_logs_s3_prefix = "flow-logs/"
  }
}

variable "ga_flow_logs_expiration_days" {
  default = "7"
}

# bucket for storing GA flow logs
resource "aws_s3_bucket" "ga_flow_logs" {
  bucket        = "${var.app}-${var.common_environment}-ga-flow-logs2"
  tags          = var.tags
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ga_flow_logs" {
  bucket = aws_s3_bucket.ga_flow_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "auto-delete-incomplete" {
  bucket = aws_s3_bucket.ga_flow_logs.id

  rule {
    id     = "cleanup"
    prefix = ""
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }

    expiration {
      days = var.ga_flow_logs_expiration_days
    }
  }
}

# Main GA Listener

resource "aws_globalaccelerator_listener" "doppler" {
  accelerator_arn = aws_globalaccelerator_accelerator.doppler.id
  client_affinity = "SOURCE_IP"
  protocol        = "TCP"

  port_range {
    from_port = 443
    to_port   = 443
  }
}

# Endpoint groups
# As we add more environments, we'll need to add them here to be a part of ga

resource "aws_globalaccelerator_endpoint_group" "doppler_us_east_1" {
  depends_on              = [module.us_east_1.lb_arn]
  listener_arn            = aws_globalaccelerator_listener.doppler.id
  endpoint_group_region   = "us-east-1"
  traffic_dial_percentage = 100

  // us east 1
  endpoint_configuration {
    client_ip_preservation_enabled = true
    endpoint_id                    = module.us_east_1.lb_arn
    weight                         = 100
  }
}

resource "aws_globalaccelerator_endpoint_group" "doppler_us_west_2" {
  depends_on              = [module.us_west_2.lb_arn]
  listener_arn            = aws_globalaccelerator_listener.doppler.id
  endpoint_group_region   = "us-west-2"
  traffic_dial_percentage = 100

  // us west 2
  endpoint_configuration {
    client_ip_preservation_enabled = true
    endpoint_id                    = module.us_west_2.lb_arn
    weight                         = 100
  }
}

