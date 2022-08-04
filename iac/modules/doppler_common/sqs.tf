resource "aws_sqs_queue" "dlq" {
  name                      = "${local.ns}-dlq"
  delay_seconds             = 0
  max_message_size          = 262144 # max
  message_retention_seconds = 86400  # 24 hours

  # To allow your function time to process each batch of records, set the source queue's visibility timeout to at least 6 times the timeout that you configure on your function. The extra time allows for Lambda to retry if your function execution is throttled while your function is processing a previous batch. 
  visibility_timeout_seconds = 60

  receive_wait_time_seconds         = 0
  tags                              = var.tags
  kms_master_key_id                 = aws_kms_key.sqs.arn
  kms_data_key_reuse_period_seconds = 86400
}

resource "aws_kms_key" "sqs" {
  description             = "SQS KMS Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags                    = var.tags

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "key-consolepolicy-3",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow use of the key",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${aws_iam_role.app_role.arn}"
        ]
      },
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "*"
    },
    {
      "Sid": "Allow attachment of persistent resources",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${aws_iam_role.app_role.arn}"
        ]
      },
      "Action": [
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:RevokeGrant"
      ],
      "Resource": "*",
      "Condition": {
        "Bool": {
          "kms:GrantIsForAWSResource": "true"
        }
      }
    }
  ]
} 
EOF
}
