variable "shard_count" {
  type    = number
  default = 1
}

variable "firehose_buffer_size" {
  type    = number
  default = 8
}

variable "firehose_buffer_interval" {
  type    = number
  default = 60
}

resource "aws_kinesis_stream" "main" {
  name             = local.ns
  retention_period = 24
  shard_count      = var.shard_count
  encryption_type  = "KMS"
  kms_key_id       = aws_kms_key.kinesis.id
  tags             = var.tags

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }
}

resource "aws_kms_key" "kinesis" {
  description             = "KMS Key for ${local.ns}"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags                    = var.tags
}

resource "aws_cloudwatch_log_group" "firehose" {
  name = "${local.ns}-firehose"
}

resource "aws_cloudwatch_log_stream" "firehose" {
  name           = "${local.ns}-firehose"
  log_group_name = aws_cloudwatch_log_group.firehose.name
}

resource "aws_kinesis_firehose_delivery_stream" "main" {
  name        = local.ns
  tags        = var.tags
  destination = "extended_s3"

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.main.arn
    role_arn           = aws_iam_role.firehose.arn
  }

  extended_s3_configuration {
    role_arn           = aws_iam_role.firehose.arn
    buffer_size        = var.firehose_buffer_size
    buffer_interval    = var.firehose_buffer_interval
    compression_format = "GZIP"

    # s3
    bucket_arn = var.s3_target_bucket_arn
    prefix     = "main/year=!{timestamp:YYYY}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"

    # logging
    error_output_prefix = "errors"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.firehose.name
      log_stream_name = aws_cloudwatch_log_stream.firehose.name
    }

    # # ... other configuration ...
    # data_format_conversion_configuration {
    #   input_format_configuration {
    #     deserializer {
    #       open_x_json_ser_de {}
    #     }
    #   }

    #   output_format_configuration {
    #     serializer {
    #       parquet_ser_de {
    #         compression = "GZIP"
    #       }
    #     }
    #   }
    #   schema_configuration {
    #     database_name = aws_glue_catalog_database.glue_catalog_database.name
    #     role_arn      = aws_iam_role.firehose_iam_role.arn
    #     table_name    = aws_glue_catalog_table.glue_catalog_table_main.name
    #     version_id    = "LATEST"
    #     region        = var.region
    #   }
    # }
  }
}

resource "aws_cloudwatch_log_group" "personalize_firehose" {
  name = "/aws/kinesisfirehose/kinesis-personalize--${local.ns}"
}

resource "aws_cloudwatch_log_stream" "personalize_firehose" {
  name           = "kinesis-personalize--${local.ns}"
  log_group_name = aws_cloudwatch_log_group.personalize_firehose.name
}

resource "aws_kinesis_firehose_delivery_stream" "personalize" {
  name        = "kinesis-personalize--${local.ns}"
  tags        = var.tags
  destination = "extended_s3"

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.main.arn
    role_arn           = aws_iam_role.personalize_firehose.arn
  }

  extended_s3_configuration {
    role_arn           = aws_iam_role.personalize_firehose.arn
    buffer_size        = var.firehose_buffer_size
    buffer_interval    = var.firehose_buffer_interval
    compression_format = "GZIP"

    # s3
    bucket_arn = aws_s3_bucket.personalize.arn
    prefix     = "firehose/data/${var.environment}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"

    # logging
    error_output_prefix = "firehose/error/${var.environment}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/!{firehose:error-output-type}"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.personalize_firehose.name
      log_stream_name = aws_cloudwatch_log_stream.personalize_firehose.name
    }

    processing_configuration {
      enabled = true

      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:prism-personalize-firehose-filter-apicall-${var.environment}:$LATEST"
        }
        parameters {
          parameter_name  = "BufferSizeInMBs"
          parameter_value = "1"
        }
        parameters {
          parameter_name  = "BufferIntervalInSeconds"
          parameter_value = "300"
        }
      }
    }
  }
}

resource "aws_iam_role" "firehose" {
  name               = "${local.ns}-firehose"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume.json
  tags               = var.tags
}

resource "aws_iam_role" "personalize_firehose" {
  name               = "kinesis-personalize--${local.ns}"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume.json
  tags               = var.tags
}

data "aws_iam_policy_document" "firehose_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "firehose" {
  name   = "${local.ns}-firehose"
  role   = aws_iam_role.firehose.name
  policy = data.aws_iam_policy_document.firehose.json
}

resource "aws_iam_role_policy" "personalize_firehose" {
  name   = "kinesis-personalize--${local.ns}"
  role   = aws_iam_role.personalize_firehose.name
  policy = data.aws_iam_policy_document.firehose.json
}

data "aws_iam_policy_document" "firehose" {

  # access to the data stream
  statement {
    actions = [
      "kinesis:DescribeStream",
      "kinesis:GetShardIterator",
      "kinesis:GetRecords",
      "kinesis:ListShards"
    ]
    resources = [aws_kinesis_stream.main.arn]
  }

  # use of encryption keys
  statement {
    actions = [
      "kms:*",
    ]
    resources = [
      aws_kms_key.kinesis.arn,
      var.s3_target_bucket_kms_arn,
      aws_kms_key.s3.arn,
    ]
  }

  # s3 access
  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
    ]
    resources = [
      var.s3_target_bucket_arn,
      "${var.s3_target_bucket_arn}/*",
      aws_s3_bucket.personalize.arn,
      "${aws_s3_bucket.personalize.arn}/*"
    ]
  }

  # lambda invoke
  statement {
    actions = [
      "lambda:InvokeFunction",
    ]
    resources = [
      "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:prism-personalize-firehose-filter-apicall-${var.environment}:$LATEST"
    ]
  }

  # logging access
  statement {
    actions   = ["logs:PutLogEvents"]
    resources = [aws_cloudwatch_log_stream.firehose.arn, aws_cloudwatch_log_stream.personalize_firehose.arn]
  }
}
