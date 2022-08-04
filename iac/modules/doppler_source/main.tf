module "doppler" {
  source                      = "../doppler_common"
  app                         = var.app
  internal                    = var.internal
  container_port              = var.container_port
  kpl_port                    = var.kpl_port
  log_level                   = var.log_level
  replicas                    = var.replicas
  health_check                = var.health_check
  saml_role                   = var.saml_role
  shard_count                 = var.shard_count
  firehose_buffer_size        = var.firehose_buffer_size
  firehose_buffer_interval    = var.firehose_buffer_interval
  deregistration_delay        = var.deregistration_delay
  environment                 = var.environment
  region                      = var.region
  vpc                         = var.vpc
  private_subnets             = var.private_subnets
  public_subnets              = var.public_subnets
  tags                        = var.tags
  s3_target_bucket_arn        = aws_s3_bucket.target.arn
  s3_target_bucket_id         = aws_s3_bucket.target.id
  s3_target_bucket_kms_arn    = aws_kms_key.s3.arn
  route53_zone_id             = var.route53_zone_id
  hosted_zone                 = var.hosted_zone
  common_subdomain            = var.common_subdomain
  identity_domain             = var.identity_domain
  identity_zone_id            = var.identity_zone_id
  telemetry_domain            = var.telemetry_domain
  telemetry_zone_id           = var.telemetry_zone_id
  ecs_autoscale_min_instances = var.ecs_autoscale_min_instances
  ecs_autoscale_max_instances = var.ecs_autoscale_max_instances
}

output "lb_dns" {
  value = module.doppler.lb_dns
}

output "lb_zone_id" {
  value = module.doppler.lb_zone_id
}

output "lb_arn" {
  value      = module.doppler.lb_arn
  depends_on = [module.doppler.lb_arn]
}

output "lb_arn_suffix" {
  value = module.doppler.lb_arn_suffix
}

output "lb_tg_arn_suffix" {
  value = module.doppler.lb_tg_arn_suffix
}

output "ecs_cluster_name" {
  value = module.doppler.ecs_cluster_name
}

output "ecs_service_name" {
  value = module.doppler.ecs_service_name
}

output "kinesis_stream_name" {
  value = module.doppler.kinesis_stream_name
}

output "firehose_delivery_stream_name" {
  value = module.doppler.firehose_delivery_stream_name
}
