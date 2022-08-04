variable "enable_data_archival" {
  type        = bool
  description = "flag to indicate whether data from s3 need to move to glacier"
  default     = false
}

variable "data_transition_duration_in_days" {
  type        = number
  description = "specifies the number of days after objects will be moved to glacier after creation."
  default     = 14
}

resource "aws_s3_bucket" "target" {
  bucket        = var.target_bucket_name
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "target" {
  bucket = aws_s3_bucket.target.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
  }
}

resource "aws_s3_bucket_versioning" "target" {
  bucket = aws_s3_bucket.target.id

  # stuff for cross region replication
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.target.id

  rule {
    id     = "auto-delete-incomplete-after-x-days"
    prefix = "auto-delete"
    status = "Enabled"
    abort_incomplete_multipart_upload {
      days_after_initiation = 3
    }
  }

  rule {
    status = var.enable_data_archival ? "Enabled" : "Disabled"
    id     = "move-to-glacier-after-few-weeks"
    prefix = "glacier"
    transition {
      storage_class = "GLACIER"
      days          = var.data_transition_duration_in_days
    }
  }
}

resource "aws_kms_key" "s3" {
  description             = "KMS Key for ${local.ns} s3 bucket"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags                    = var.tags
}

resource "aws_kms_alias" "s3" {
  name          = "alias/${aws_s3_bucket.target.bucket}-key"
  target_key_id = aws_kms_key.s3.key_id
}
