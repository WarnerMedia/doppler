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

resource "aws_s3_bucket_replication_configuration" "target" {
  depends_on = [aws_s3_bucket_versioning.target]

  bucket = aws_s3_bucket.target.id
  role   = aws_iam_role.replication.arn

  rule {
    id     = "${var.app}-${var.environment}-repl-source-to-dest"
    status = "Enabled"

    destination {
      bucket        = var.destination_target_bucket_arn
      storage_class = "STANDARD"

      encryption_configuration {
        replica_kms_key_id = var.destination_target_bucket_kms_arn
      }
    }

    source_selection_criteria {
      sse_kms_encrypted_objects {
        status = "Enabled"
      }
    }
  }
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

resource "aws_iam_role" "replication" {
  name = "${var.app}-${var.environment}-replication-role-west"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "replication" {
  name = "${var.app}-${var.environment}-replication-role-policy-west"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
          "s3:ListBucket",
          "s3:GetReplicationConfiguration",
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging",
          "s3:GetObjectRetention",
          "s3:GetObjectLegalHold"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.target.arn}",
        "${aws_s3_bucket.target.arn}/*"        
      ]
    },
    {
      "Action": [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags",
          "s3:GetObjectVersionTagging"
      ],
      "Effect": "Allow",
      "Resource": "${var.destination_target_bucket_arn}/*"
    },
    {
      "Action": [
        "kms:Decrypt"
      ],
      "Effect": "Allow",
      "Condition": {
        "StringLike": {
          "kms:ViaService": "s3.${var.region}.amazonaws.com",
          "kms:EncryptionContext:aws:s3:arn": [
            "${aws_s3_bucket.target.arn}/*"
          ]
        }
      },
      "Resource": [
        "${aws_kms_key.s3.arn}"
      ]
    },
    {
      "Action": [
        "kms:Encrypt"
      ],
      "Effect": "Allow",
      "Condition": {
        "StringLike": {
          "kms:ViaService": "s3.${var.destination_region}.amazonaws.com",
          "kms:EncryptionContext:aws:s3:arn": [
            "${var.destination_target_bucket_arn}/*"
          ]
        }
      },
      "Resource": [
          "${var.destination_target_bucket_kms_arn}"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "replication" {
  role       = aws_iam_role.replication.name
  policy_arn = aws_iam_policy.replication.arn
}
