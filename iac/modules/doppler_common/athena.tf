resource "aws_athena_workgroup" "main" {
  name = local.ns
  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true
    result_configuration {
      output_location = "s3://${var.s3_target_bucket_id}/output/"
    }
  }
  tags = var.tags
}

resource "aws_glue_catalog_database" "main" {
  name = local.ns
}

resource "aws_glue_catalog_table" "registration" {
  name          = "registration"
  database_name = aws_glue_catalog_database.main.name
  table_type    = "EXTERNAL_TABLE"
  storage_descriptor {
    location      = "s3://${var.s3_target_bucket_id}/main"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.IgnoreKeyTextOutputFormat"
    ser_de_info {
      name                  = local.ns
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"
    }
    columns {
      name = "date"
      type = "timestamp"
    }
    columns {
      name = "wmukid"
      type = "string"
    }
    columns {
      name = "appid"
      type = "string"
    }
    columns {
      name = "brand"
      type = "string"
    }
    columns {
      name = "domain"
      type = "string"
    }
    columns {
      name = "useragent"
      type = "string"
    }
    columns {
      name = "platform"
      type = "string"
    }
    columns {
      name = "wmhhid"
      type = "string"
    }
    columns {
      name = "wminid"
      type = "string"
    }
    columns {
      name = "ip"
      type = "string"
    }
    columns {
      name = "city"
      type = "string"
    }
    columns {
      name = "state"
      type = "string"
    }
    columns {
      name = "zips"
      type = "string"
    }
    columns {
      name = "country"
      type = "string"
    }
    columns {
      name = "cookies"
      type = "string"
    }
    columns {
      name = "ids"
      type = "string"
    }
    columns {
      name = "servereventid"
      type = "string"
    }
  }
}
