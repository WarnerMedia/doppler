resource "aws_s3_bucket" "lblogs_athena" {
  bucket        = "${var.app}-athena-${var.environment}"
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lblogs_athena" {
  bucket = aws_s3_bucket.lblogs_athena.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.lblogs_athena.arn
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lblogs_athena" {
  bucket = aws_s3_bucket.lblogs_athena.id

  rule {
    id     = "auto-delete-incomplete-after-x-days"
    prefix = ""
    status = "Enabled"
    abort_incomplete_multipart_upload {
      days_after_initiation = 3
    }
  }
}

resource "aws_kms_key" "lblogs_athena" {
  enable_key_rotation = true
  tags                = var.tags
}

resource "aws_kms_alias" "lblogs_athena" {
  name          = "alias/${aws_s3_bucket.lblogs_athena.bucket}-key"
  target_key_id = aws_kms_key.lblogs_athena.key_id
}

resource "aws_athena_database" "lblogs_athena" {
  name   = "${var.app}_lblogs_${var.environment}"
  bucket = aws_s3_bucket.lblogs_athena.id
}

resource "aws_athena_named_query" "lblogs_athena" {
  name     = "${local.ns}-create-table"
  database = aws_athena_database.lblogs_athena.name
  query    = data.template_file.lblogs_athena.rendered
}

data "template_file" "lblogs_athena" {

  vars = {
    bucket     = aws_s3_bucket.lb_access_logs.id
    account_id = data.aws_caller_identity.current.account_id
    region     = var.region
  }

  template = <<EOF
CREATE EXTERNAL TABLE IF NOT EXISTS lb_logs (
  type string,
  time string,
  elb string,
  client_ip string,
  client_port int,
  target_ip string,
  target_port int,
  request_processing_time double,
  target_processing_time double,
  response_processing_time double,
  elb_status_code string,
  target_status_code string,
  received_bytes bigint,
  sent_bytes bigint,
  request_verb string,
  request_url string,
  request_proto string,
  user_agent string,
  ssl_cipher string,
  ssl_protocol string,
  target_group_arn string,
  trace_id string,
  domain_name string,
  chosen_cert_arn string,
  matched_rule_priority string,
  request_creation_time string,
  actions_executed string,
  redirect_url string,
  new_field string
  )
  ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.RegexSerDe'
  WITH SERDEPROPERTIES (
  'serialization.format' = '1',
  'input.regex' = '([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*):([0-9]*) ([^ ]*)[:-]([0-9]*) ([-.0-9]*) ([-.0-9]*) ([-.0-9]*) (|[-0-9]*) (-|[-0-9]*) ([-0-9]*) ([-0-9]*) \"([^ ]*) ([^ ]*) (- |[^ ]*)\" \"([^\"]*)\" ([A-Z0-9-]+) ([A-Za-z0-9.-]*) ([^ ]*) \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" ([-.0-9]*) ([^ ]*) \"([^\"]*)\"($| \"[^ ]*\")(.*)')
  LOCATION 's3://$${bucket}/AWSLogs/$${account_id}/elasticloadbalancing/$${region}/';  
EOF
}
