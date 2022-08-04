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

resource "aws_s3_bucket" "personalize" {
  bucket        = "prism-personalize-streaming-${var.environment}"
  force_destroy = true
  tags          = var.tags

}

resource "aws_s3_bucket_server_side_encryption_configuration" "personalize" {
  bucket = aws_s3_bucket.personalize.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
  }
}

resource "aws_s3_bucket_versioning" "personalize" {
  bucket = aws_s3_bucket.personalize.id

  # stuff for cross region replication
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "personalize-lifecycle" {
  bucket = aws_s3_bucket.personalize.id

  rule {
    id     = "auto-delete-incomplete-after-x-days"
    prefix = "personalize-auto-delete"
    status = "Enabled"
    abort_incomplete_multipart_upload {
      days_after_initiation = 3
    }
  }

  rule {
    status = var.enable_data_archival ? "Enabled" : "Disabled"
    id     = "move-to-glacier-after-few-weeks"
    prefix = "personalize-glacier"
    transition {
      storage_class = "GLACIER"
      days          = var.data_transition_duration_in_days
    }
  }
}

resource "aws_kms_key" "s3" {
  description             = "KMS Key for prism-personalize-streaming-${var.environment} s3 bucket"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags                    = var.tags
}

resource "aws_kms_alias" "s3" {
  name          = "alias/${aws_s3_bucket.personalize.bucket}-key"
  target_key_id = aws_kms_key.s3.key_id
}
