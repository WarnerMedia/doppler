# output

# Command to view the status of the Fargate service
output "status" {
  value = "fargate service info"
}

# Command to deploy a new task definition to the service using Docker Compose
output "deploy" {
  value = "fargate service deploy -f docker-compose.yml"
}

# Command to scale up cpu and memory
output "scale_up" {
  value = "fargate service update -h"
}

# Command to scale out the number of tasks (container replicas)
output "scale_out" {
  value = "fargate service scale -h"
}

output "lb_dns" {
  value = aws_alb.main.dns_name
}

output "lb_zone_id" {
  value = aws_alb.main.zone_id
}

output "lb_arn" {
  value      = aws_alb.main.arn
  depends_on = [aws_alb.main]
}

output "lb_arn_suffix" {
  value      = aws_alb.main.arn_suffix
  depends_on = [aws_alb.main]
}

output "lb_tg_arn_suffix" {
  value = aws_alb_target_group.main.arn_suffix
}

output "ecs_cluster_name" {
  value      = aws_ecs_cluster.app.name
  depends_on = [aws_ecs_cluster.app]
}

output "ecs_service_name" {
  value      = aws_ecs_service.app.name
  depends_on = [aws_ecs_service.app]
}

output "kinesis_stream_name" {
  value = aws_kinesis_stream.main.name
}

output "firehose_delivery_stream_name" {
  value = aws_kinesis_firehose_delivery_stream.main.name
}

output "endpoint" {
  value = "https://${local.subdomain}"
}
