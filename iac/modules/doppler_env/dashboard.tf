resource "aws_cloudwatch_dashboard" "cloudwatch_dashboard" {
  dashboard_name = "${var.app}-${var.common_environment}"

  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 6,
      "y": 30,
      "width": 6,
      "height": 6,
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "metrics": [
          [
            "AWS/ECS",
            "MemoryUtilization",
            "ServiceName",
            "${module.us_east_1.ecs_service_name}",
            "ClusterName",
            "${module.us_east_1.ecs_cluster_name}",
            {
              "color": "#1f77b4"
            }
          ],
          [
            ".",
            "CPUUtilization",
            ".",
            ".",
            ".",
            ".",
            {
              "color": "#9467bd"
            }
          ],
          [
            "...",
            "${module.us_west_2.ecs_service_name}",
            ".",
            "${module.us_west_2.ecs_cluster_name}",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            "MemoryUtilization",
            ".",
            ".",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "region": "us-east-1",
        "period": 300,
        "title": "Memory and CPU utilization",
        "yAxis": {
          "left": {
            "min": 0,
            "max": 100
          }
        }
      }
    },
    {
      "type": "metric",
      "x": 9,
      "y": 18,
      "width": 9,
      "height": 6,
      "properties": {
        "view": "timeSeries",
        "stacked": true,
        "metrics": [
          [
            "AWS/ApplicationELB",
            "HTTPCode_Target_5XX_Count",
            "TargetGroup",
            "${module.us_east_1.lb_tg_arn_suffix}",
            "LoadBalancer",
            "${module.us_east_1.lb_arn_suffix}",
            {
              "period": 60,
              "color": "#d62728",
              "stat": "Sum"
            }
          ],
          [
            ".",
            "HTTPCode_Target_4XX_Count",
            ".",
            ".",
            ".",
            ".",
            {
              "period": 60,
              "stat": "Sum",
              "color": "#bcbd22"
            }
          ],
          [
            ".",
            "HTTPCode_Target_3XX_Count",
            ".",
            ".",
            ".",
            ".",
            {
              "period": 60,
              "stat": "Sum",
              "color": "#98df8a"
            }
          ],
          [
            ".",
            "HTTPCode_Target_2XX_Count",
            ".",
            ".",
            ".",
            ".",
            {
              "period": 60,
              "stat": "Sum",
              "color": "#2ca02c"
            }
          ]
        ],
        "region": "us-east-1",
        "title": "us-east-1 Container responses",
        "period": 300,
        "yAxis": {
          "left": {
            "min": 0
          }
        }
      }
    },
    {
      "type": "metric",
      "x": 18,
      "y": 18,
      "width": 6,
      "height": 6,
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "metrics": [
          [
            "AWS/ApplicationELB",
            "TargetResponseTime",
            "LoadBalancer",
            "${module.us_east_1.lb_arn_suffix}",
            {
              "period": 60,
              "stat": "p50"
            }
          ],
          [
            "...",
            {
              "period": 60,
              "stat": "p90",
              "color": "#c5b0d5"
            }
          ],
          [
            "...",
            {
              "period": 60,
              "stat": "p99",
              "color": "#dbdb8d"
            }
          ]
        ],
        "region": "us-east-1",
        "period": 300,
        "yAxis": {
          "left": {
            "min": 0,
            "max": 3
          }
        },
        "title": "us-east-1 Container response times"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 18,
      "width": 9,
      "height": 6,
      "properties": {
        "view": "timeSeries",
        "stacked": true,
        "metrics": [
          [
            "AWS/ApplicationELB",
            "HTTPCode_Target_5XX_Count",
            "LoadBalancer",
            "${module.us_east_1.lb_arn_suffix}",
            {
              "period": 60,
              "stat": "Sum",
              "color": "#d62728"
            }
          ],
          [
            ".",
            "HTTPCode_Target_4XX_Count",
            ".",
            ".",
            {
              "period": 60,
              "stat": "Sum",
              "color": "#bcbd22"
            }
          ],
          [
            ".",
            "HTTPCode_Target_3XX_Count",
            ".",
            ".",
            {
              "period": 60,
              "stat": "Sum",
              "color": "#98df8a"
            }
          ],
          [
            ".",
            "HTTPCode_Target_2XX_Count",
            ".",
            ".",
            {
              "period": 60,
              "stat": "Sum",
              "color": "#2ca02c"
            }
          ]
        ],
        "region": "us-east-1",
        "title": "us-east-1 Load balancer responses",
        "period": 300,
        "yAxis": {
          "left": {
            "min": 0
          }
        }
      }
    },
    {
      "type": "metric",
      "x": 6,
      "y": 48,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "KinesisProducerLibrary",
            "RetriesPerRecord",
            "StreamName",
            "${module.us_east_1.kinesis_stream_name}"
          ],
          [
            "...",
            "${module.us_west_2.kinesis_stream_name}",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "KPL retries",
        "period": 300,
        "stat": "Sum"
      }
    },
    {
      "type": "metric",
      "x": 18,
      "y": 36,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/Kinesis",
            "PutRecords.Records",
            "StreamName",
            "${module.us_east_1.kinesis_stream_name}"
          ],
          [
            "...",
            "${module.us_west_2.kinesis_stream_name}",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "kinesis records",
        "period": 1,
        "stat": "Maximum"
      }
    },
    {
      "type": "metric",
      "x": 12,
      "y": 36,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/Kinesis",
            "WriteProvisionedThroughputExceeded",
            "StreamName",
            "${module.us_east_1.kinesis_stream_name}",
            {
              "color": "#d62728"
            }
          ],
          [
            "...",
            "${module.us_west_2.kinesis_stream_name}",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": true,
        "region": "us-east-1",
        "title": "throughput exceeded",
        "period": 1,
        "stat": "Maximum"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 36,
      "width": 6,
      "height": 6,
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "metrics": [
          [
            "AWS/Kinesis",
            "PutRecords.Latency",
            "StreamName",
            "${module.us_east_1.kinesis_stream_name}"
          ],
          [
            "...",
            "${module.us_west_2.kinesis_stream_name}",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "region": "us-east-1",
        "title": "kinesis latency",
        "period": 300
      }
    },
    {
      "type": "metric",
      "x": 15,
      "y": 30,
      "width": 3,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "ECS/ContainerInsights",
            "CpuUtilized",
            "ServiceName",
            "${module.us_east_1.ecs_service_name}",
            "ClusterName",
            "${module.us_east_1.ecs_cluster_name}"
          ],
          [
            "...",
            "${module.us_west_2.ecs_service_name}",
            ".",
            "${module.us_west_2.ecs_cluster_name}",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "cpu(In Units not percentage)",
        "period": 300,
        "stat": "Average"
      }
    },
    {
      "type": "metric",
      "x": 12,
      "y": 30,
      "width": 3,
      "height": 6,
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "metrics": [
          [
            "ECS/ContainerInsights",
            "RunningTaskCount",
            "ServiceName",
            "${module.us_east_1.ecs_service_name}",
            "ClusterName",
            "${module.us_east_1.ecs_cluster_name}"
          ],
          [
            "...",
            "${module.us_west_2.ecs_service_name}",
            ".",
            "${module.us_west_2.ecs_cluster_name}",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "region": "us-east-1",
        "title": "containers",
        "period": 300
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 30,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "ECS/ContainerInsights",
            "MemoryUtilized",
            "ServiceName",
            "${module.us_east_1.ecs_service_name}",
            "ClusterName",
            "${module.us_east_1.ecs_cluster_name}"
          ],
          [
            "...",
            "${module.us_west_2.ecs_service_name}",
            ".",
            "${module.us_west_2.ecs_cluster_name}",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "memory",
        "period": 300,
        "stat": "Average"
      }
    },
    {
      "type": "metric",
      "x": 12,
      "y": 42,
      "width": 6,
      "height": 6,
      "properties": {
        "view": "timeSeries",
        "stacked": true,
        "metrics": [
          [
            "KinesisProducerLibrary",
            "AllErrors",
            "StreamName",
            "${module.us_east_1.kinesis_stream_name}"
          ],
          [
            ".",
            "BufferingTime",
            ".",
            "."
          ],
          [
            ".",
            "KinesisRecordsDataPut",
            ".",
            "."
          ],
          [
            ".",
            "KinesisRecordsPut",
            ".",
            "."
          ],
          [
            ".",
            "RetriesPerRecord",
            ".",
            "."
          ],
          [
            ".",
            "UserRecordsDataPut",
            ".",
            "."
          ],
          [
            ".",
            "UserRecordsPending",
            ".",
            "."
          ],
          [
            ".",
            "UserRecordsPut",
            ".",
            "."
          ],
          [
            ".",
            "UserRecordsReceived",
            ".",
            "."
          ]
        ],
        "region": "us-east-1",
        "title": "us-east-1 KPL"
      }
    },
    {
      "type": "metric",
      "x": 6,
      "y": 42,
      "width": 6,
      "height": 6,
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "metrics": [
          [
            "AWS/Firehose",
            "DeliveryToS3.DataFreshness",
            "DeliveryStreamName",
            "${module.us_east_1.firehose_delivery_stream_name}"
          ],
          [
            "...",
            "${module.us_west_2.firehose_delivery_stream_name}",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "region": "us-east-1",
        "title": "Firehose Data Freshness",
        "period": 300
      }
    },
    {
      "type": "metric",
      "x": 6,
      "y": 36,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/Firehose",
            "DeliveryToS3.Records",
            "DeliveryStreamName",
            "${module.us_east_1.firehose_delivery_stream_name}",
            {
              "color": "#2ca02c"
            }
          ],
          [
            "...",
            "${module.us_west_2.firehose_delivery_stream_name}",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "Firehose Delivered Records",
        "stat": "Average",
        "period": 300
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 42,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/Firehose",
            "DeliveryToS3.Success",
            "DeliveryStreamName",
            "${module.us_east_1.firehose_delivery_stream_name}",
            {
              "color": "#2ca02c"
            }
          ],
          [
            "...",
            "${module.us_west_2.firehose_delivery_stream_name}",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "Firehose success",
        "stat": "Average",
        "period": 300
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 21,
      "height": 6,
      "properties": {
        "view": "timeSeries",
        "stacked": true,
        "metrics": [
          [
            "AWS/ApplicationELB",
            "HTTPCode_Target_5XX_Count",
            "LoadBalancer",
            "${module.us_east_1.lb_arn_suffix}",
            {
              "period": 60,
              "stat": "Sum",
              "color": "#d62728"
            }
          ],
          [
            ".",
            "HTTPCode_Target_4XX_Count",
            ".",
            ".",
            {
              "period": 60,
              "stat": "Sum",
              "color": "#bcbd22"
            }
          ],
          [
            ".",
            "HTTPCode_Target_3XX_Count",
            ".",
            ".",
            {
              "period": 60,
              "stat": "Sum",
              "color": "#98df8a"
            }
          ],
          [
            ".",
            "HTTPCode_Target_2XX_Count",
            ".",
            ".",
            {
              "period": 60,
              "stat": "Sum",
              "color": "#2ca02c"
            }
          ],
          [
            "...",
            "${module.us_west_2.lb_arn_suffix}",
            {
              "period": 60,
              "stat": "Sum",
              "region": "us-west-2"
            }
          ],
          [
            ".",
            "HTTPCode_Target_4XX_Count",
            ".",
            ".",
            {
              "period": 60,
              "stat": "Sum",
              "region": "us-west-2"
            }
          ],
          [
            ".",
            "HTTPCode_Target_5XX_Count",
            ".",
            ".",
            {
              "period": 60,
              "stat": "Sum",
              "region": "us-west-2"
            }
          ],
          [
            ".",
            "HTTPCode_Target_3XX_Count",
            ".",
            ".",
            {
              "period": 60,
              "stat": "Sum",
              "region": "us-west-2"
            }
          ]
        ],
        "region": "us-east-1",
        "title": "Load balancer responses",
        "period": 300,
        "yAxis": {
          "left": {
            "min": 0
          }
        }
      }
    },
    {
      "type": "metric",
      "x": 18,
      "y": 30,
      "width": 6,
      "height": 6,
      "properties": {
        "region": "us-east-1",
        "metrics": [
          [
            "AWS/ECS",
            "CPUUtilization",
            "ClusterName",
            "${module.us_east_1.ecs_cluster_name}",
            "ServiceName",
            "${module.us_east_1.ecs_service_name}",
            {
              "stat": "Average"
            }
          ],
          [
            "...",
            "ServiceName",
            "${module.us_west_2.ecs_service_name}",
            "ClusterName",
            "${module.us_west_2.ecs_cluster_name}",
            {
              "stat": "Average",
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "period": 60,
        "annotations": {
          "horizontal": [
            {
              "label": "CPUUtilization >= 70 for 1 datapoints within 1 minute",
              "value": 70
            }
          ]
        },
        "title": "CPU-Utilization-High-70",
        "yAxis": {
          "left": {
            "min": 0
          }
        }
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 6,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/ApplicationELB",
            "UnHealthyHostCount",
            "TargetGroup",
            "${module.us_east_1.lb_tg_arn_suffix}",
            "LoadBalancer",
            "${module.us_east_1.lb_arn_suffix}",
            {
              "color": "#d62728"
            }
          ],
          [
            "...",
            "${module.us_west_2.lb_tg_arn_suffix}",
            ".",
            "${module.us_west_2.lb_arn_suffix}",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "period": 60,
        "region": "us-east-1",
        "stat": "Average",
        "title": "Unhealthy Hosts",
        "yAxis": {
          "left": {
            "min": 0
          }
        },
        "view": "timeSeries",
        "stacked": false
      }
    },
    {
      "type": "metric",
      "x": 6,
      "y": 6,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/ApplicationELB",
            "HealthyHostCount",
            "TargetGroup",
            "${module.us_east_1.lb_tg_arn_suffix}",
            "LoadBalancer",
            "${module.us_east_1.lb_arn_suffix}",
            {
              "color": "#2ca02c"
            }
          ],
          [
            "...",
            "${module.us_west_2.lb_tg_arn_suffix}",
            ".",
            "${module.us_west_2.lb_arn_suffix}",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "period": 60,
        "region": "us-east-1",
        "stat": "Average",
        "title": "Healthy Hosts",
        "yAxis": {
          "left": {
            "min": 0
          }
        },
        "view": "timeSeries",
        "stacked": false
      }
    },
    {
      "type": "metric",
      "x": 12,
      "y": 6,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/ApplicationELB",
            "TargetResponseTime",
            "TargetGroup",
            "${module.us_east_1.lb_tg_arn_suffix}",
            "LoadBalancer",
            "${module.us_east_1.lb_arn_suffix}",
            {
              "color": "#ff7f0e"
            }
          ],
          [
            "...",
            "${module.us_west_2.lb_tg_arn_suffix}",
            ".",
            "${module.us_west_2.lb_arn_suffix}",
            {
              "region": "us-west-2",
              "color": "#9467bd"
            }
          ]
        ],
        "period": 60,
        "region": "us-east-1",
        "stat": "Average",
        "title": "Target Response Time",
        "yAxis": {
          "left": {
            "min": 0
          }
        },
        "view": "timeSeries",
        "stacked": false
      }
    },
    {
      "type": "metric",
      "x": 18,
      "y": 6,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/ApplicationELB",
            "RequestCount",
            "TargetGroup",
            "${module.us_east_1.lb_tg_arn_suffix}",
            "LoadBalancer",
            "${module.us_east_1.lb_arn_suffix}"
          ],
          [
            "...",
            "${module.us_west_2.lb_tg_arn_suffix}",
            ".",
            "${module.us_west_2.lb_arn_suffix}",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "period": 60,
        "region": "us-east-1",
        "stat": "Sum",
        "title": "Requests",
        "yAxis": {
          "left": {
            "min": 0
          }
        },
        "view": "timeSeries",
        "stacked": false
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 12,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/ApplicationELB",
            "HTTPCode_Target_5XX_Count",
            "TargetGroup",
            "${module.us_east_1.lb_tg_arn_suffix}",
            "LoadBalancer",
            "${module.us_east_1.lb_arn_suffix}",
            {
              "color": "#d62728"
            }
          ],
          [
            "...",
            "${module.us_west_2.lb_tg_arn_suffix}",
            ".",
            "${module.us_west_2.lb_arn_suffix}",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "period": 60,
        "region": "us-east-1",
        "stat": "Sum",
        "title": "HTTP 5XXs",
        "yAxis": {
          "left": {
            "min": 0
          }
        },
        "view": "timeSeries",
        "stacked": false
      }
    },
    {
      "type": "metric",
      "x": 6,
      "y": 12,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/ApplicationELB",
            "HTTPCode_Target_4XX_Count",
            "TargetGroup",
            "${module.us_east_1.lb_tg_arn_suffix}",
            "LoadBalancer",
            "${module.us_east_1.lb_arn_suffix}",
            {
              "color": "#d62728"
            }
          ],
          [
            "...",
            "${module.us_west_2.lb_tg_arn_suffix}",
            ".",
            "${module.us_west_2.lb_arn_suffix}",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "period": 60,
        "region": "us-east-1",
        "stat": "Sum",
        "title": "HTTP 4XXs",
        "yAxis": {
          "left": {
            "min": 0
          }
        },
        "view": "timeSeries",
        "stacked": false
      }
    },
    {
      "type": "metric",
      "x": 12,
      "y": 12,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/ApplicationELB",
            "HTTPCode_Target_3XX_Count",
            "TargetGroup",
            "${module.us_east_1.lb_tg_arn_suffix}",
            "LoadBalancer",
            "${module.us_east_1.lb_arn_suffix}",
            {
              "color": "#d62728"
            }
          ],
          [
            "...",
            "${module.us_west_2.lb_tg_arn_suffix}",
            ".",
            "${module.us_west_2.lb_arn_suffix}",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "period": 60,
        "region": "us-east-1",
        "stat": "Sum",
        "title": "HTTP 3XXs",
        "yAxis": {
          "left": {
            "min": 0
          }
        },
        "view": "timeSeries",
        "stacked": false
      }
    },
    {
      "type": "metric",
      "x": 18,
      "y": 12,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/ApplicationELB",
            "HTTPCode_Target_2XX_Count",
            "TargetGroup",
            "${module.us_east_1.lb_tg_arn_suffix}",
            "LoadBalancer",
            "${module.us_east_1.lb_arn_suffix}",
            {
              "color": "#2ca02c"
            }
          ],
          [
            "...",
            "${module.us_west_2.lb_tg_arn_suffix}",
            ".",
            "${module.us_west_2.lb_arn_suffix}",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "period": 60,
        "region": "us-east-1",
        "stat": "Sum",
        "title": "HTTP 2XXs",
        "yAxis": {
          "left": {
            "min": 0
          }
        },
        "view": "timeSeries",
        "stacked": false
      }
    },
    {
      "type": "metric",
      "x": 18,
      "y": 48,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/Kinesis",
            "PutRecords.SuccessfulRecords",
            "StreamName",
            "${module.us_east_1.kinesis_stream_name}"
          ],
          [
            "...",
            "${module.us_west_2.kinesis_stream_name}",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "stat": "Sum",
        "period": 60,
        "title": "KDS PutRecords.SuccessfulRecords"
      }
    },
    {
      "type": "metric",
      "x": 12,
      "y": 48,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/Kinesis",
            "PutRecords.FailedRecords",
            "StreamName",
            "${module.us_east_1.kinesis_stream_name}"
          ],
          [
            "...",
            "${module.us_west_2.kinesis_stream_name}",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "stat": "Sum",
        "period": 60,
        "title": "KDS PutRecords.FailedRecords"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 48,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/Kinesis",
            "PutRecords.Success",
            "StreamName",
            "${module.us_east_1.kinesis_stream_name}"
          ],
          [
            "...",
            "${module.us_west_2.kinesis_stream_name}",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "stat": "Sum",
        "period": 60,
        "title": "KDS PutRecords.Success"
      }
    },
    {
      "type": "metric",
      "x": 21,
      "y": 0,
      "width": 3,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/ApplicationELB",
            "RequestCount",
            "LoadBalancer",
            "${module.us_east_1.lb_arn_suffix}"
          ],
          [
            "...",
            "${module.us_west_2.lb_arn_suffix}",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "singleValue",
        "stacked": false,
        "region": "us-east-1",
        "stat": "Sum",
        "period": 60,
        "title": "Requests Per Minute"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 24,
      "width": 9,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/ApplicationELB",
            "HTTPCode_Target_5XX_Count",
            "LoadBalancer",
            "${module.us_west_2.lb_arn_suffix}",
            {
              "region": "us-west-2",
              "color": "#d62728"
            }
          ],
          [
            ".",
            "HTTPCode_Target_2XX_Count",
            ".",
            ".",
            {
              "region": "us-west-2",
              "color": "#2ca02c"
            }
          ],
          [
            ".",
            "HTTPCode_Target_4XX_Count",
            ".",
            ".",
            {
              "region": "us-west-2",
              "color": "#bcbd22"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": true,
        "region": "us-east-1",
        "title": "us-west-2 Load balancer responses",
        "period": 60,
        "yAxis": {
          "left": {
            "min": 0
          }
        },
        "stat": "Sum"
      }
    },
    {
      "type": "metric",
      "x": 9,
      "y": 24,
      "width": 9,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/ApplicationELB",
            "HTTPCode_Target_5XX_Count",
            "TargetGroup",
            "${module.us_west_2.lb_tg_arn_suffix}",
            "LoadBalancer",
            "${module.us_west_2.lb_arn_suffix}",
            {
              "region": "us-west-2",
              "color": "#d62728"
            }
          ],
          [
            ".",
            "HTTPCode_Target_4XX_Count",
            ".",
            ".",
            ".",
            ".",
            {
              "region": "us-west-2",
              "color": "#bcbd22"
            }
          ],
          [
            ".",
            "HTTPCode_Target_2XX_Count",
            ".",
            ".",
            ".",
            ".",
            {
              "region": "us-west-2",
              "color": "#2ca02c"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": true,
        "region": "us-east-1",
        "title": "us-west-2 Container responses",
        "period": 60,
        "yAxis": {
          "left": {
            "min": 0
          }
        },
        "stat": "Sum"
      }
    },
    {
      "type": "metric",
      "x": 18,
      "y": 24,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/ApplicationELB",
            "TargetResponseTime",
            "LoadBalancer",
            "${module.us_west_2.lb_arn_suffix}",
            {
              "region": "us-west-2",
              "stat": "p50",
              "color": "#1f77b4"
            }
          ],
          [
            "...",
            {
              "region": "us-west-2",
              "color": "#c5b0d5",
              "stat": "p90"
            }
          ],
          [
            "...",
            {
              "region": "us-west-2",
              "color": "#dbdb8d"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "period": 60,
        "yAxis": {
          "left": {
            "min": 0,
            "max": 3
          }
        },
        "title": "us-west-2 Container response times",
        "stat": "p99"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 54,
      "width": 9,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/GlobalAccelerator",
            "NewFlowCount",
            "Accelerator",
            "${aws_globalaccelerator_accelerator.doppler.id}"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-west-2",
        "title": "GA Flow Count total",
        "stat": "Sum",
        "period": 60
      }
    },
    {
      "type": "metric",
      "x": 15,
      "y": 54,
      "width": 9,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/GlobalAccelerator",
            "NewFlowCount",
            "Listener",
            "874c4192",
            "EndpointGroup",
            "us-west-2",
            "Accelerator",
            "${aws_globalaccelerator_accelerator.doppler.id}"
          ],
          [
            "...",
            "us-east-1",
            ".",
            "."
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-west-2",
        "title": "GA Flow Count by Region",
        "stat": "Sum",
        "period": 60
      }
    },
    {
      "type": "metric",
      "x": 9,
      "y": 54,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/GlobalAccelerator",
            "NewFlowCount",
            "DestinationEdge",
            "IN",
            "Accelerator",
            "${aws_globalaccelerator_accelerator.doppler.id}"
          ],
          [
            "...",
            "ZA",
            ".",
            "."
          ],
          [
            "...",
            "SA",
            ".",
            "."
          ],
          [
            "...",
            "AU",
            ".",
            "."
          ],
          [
            "...",
            "KR",
            ".",
            "."
          ],
          [
            "...",
            "ME",
            ".",
            "."
          ],
          [
            "...",
            "NA",
            ".",
            "."
          ],
          [
            "...",
            "AP",
            ".",
            "."
          ],
          [
            "...",
            "EU",
            ".",
            "."
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-west-2",
        "title": "GA Flow Count By Edge location",
        "stat": "Sum",
        "period": 60
      }
    },
    {
      "type": "metric",
      "x": 18,
      "y": 42,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "KinesisProducerLibrary",
            "AllErrors",
            "StreamName",
            "${module.us_west_2.kinesis_stream_name}",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            "BufferingTime",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            "KinesisRecordsDataPut",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            "KinesisRecordsPut",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            "RetriesPerRecord",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            "UserRecordsDataPut",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            "UserRecordsPending",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            "UserRecordsPut",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            "UserRecordsReceived",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": true,
        "region": "us-east-1",
        "title": "us-west-2 KPL",
        "period": 300,
        "stat": "Average"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 60,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/S3",
            "ReplicationLatency",
            "SourceBucket",
            "${var.target_bucket_name_us_west_2}",
            "DestinationBucket",
            "${var.target_bucket_name_us_east_1}",
            "RuleId",
            "repl-west-to-east"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "S3 Replication Latency west to east",
        "stat": "Sum",
        "period": 60
      }
    },
    {
      "type": "metric",
      "x": 6,
      "y": 60,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/S3",
            "BytesPendingReplication",
            "SourceBucket",
            "${var.target_bucket_name_us_west_2}",
            "DestinationBucket",
            "${var.target_bucket_name_us_east_1}",
            "RuleId",
            "repl-west-to-east"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "S3 Bytes Pending Repl west to east",
        "stat": "Sum",
        "period": 60
      }
    },
    {
      "type": "metric",
      "x": 12,
      "y": 60,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "CWAgent",
            "${local.nsuseast1}-MissingMediaType",
            "metric_type",
            "counter"
          ],
          [
            ".",
            "${local.nsuseast1}-NotPost",
            ".",
            "."
          ],
          [
            ".",
            "${local.nsuseast1}-UnsupportedMediaType",
            ".",
            "."
          ],
          [
            ".",
            "${local.nsuseast1}-MissingRequiredField",
            ".",
            "."
          ],
          [
            ".",
            "${local.nsuseast1}-UnableToDecodeBody",
            ".",
            "."
          ],
          [
            ".",
            "${local.nsuseast1}-UnableToReadBody",
            ".",
            "."
          ],
          [
            "CWAgent",
            "${local.nsuswest2}-MissingMediaType",
            "metric_type",
            "counter",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            "${local.nsuswest2}-NotPost",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            "${local.nsuswest2}-UnsupportedMediaType",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            "${local.nsuswest2}-MissingRequiredField",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            "${local.nsuswest2}-UnableToDecodeBody",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            "${local.nsuswest2}-UnableToReadBody",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "stat": "Sum",
        "period": 60,
        "title": "API Error Counts - Other"
      }
    },
    {
      "type": "metric",
      "x": 18,
      "y": 60,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "CWAgent",
            "${local.nsuseast1}-IsGooglebot",
            "metric_type",
            "counter"
          ],
          [
            ".",
            "${local.nsuseast1}-IsAdsBot-Google",
            ".",
            "."
          ],
          [
            "CWAgent",
            "${local.nsuswest2}-IsGooglebot",
            "metric_type",
            "counter",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            "${local.nsuswest2}-IsAdsBot-Google",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "stat": "Sum",
        "period": 60,
        "title": "API Error Counts - GoogleBots"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 66,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "CWAgent",
            "${local.nsuseast1}-Timer",
            "metric_type",
            "timing"
          ],
          [
            "CWAgent",
            "${local.nsuswest2}-Timer",
            "metric_type",
            "timing",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "stat": "Average",
        "period": 60,
        "title": "API timing - Happy path",
        "yAxis": {
          "left": {
            "label": "milliseconds",
            "showUnits": false
          }
        }
      }
    }
  ]
}
EOF
}
