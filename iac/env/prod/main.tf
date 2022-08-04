# main.tf
module "prod" {
  source                   = "../../modules/doppler_env"
  app                      = var.app
  aws_profile              = var.aws_profile
  internal                 = var.internal
  container_port           = var.container_port
  kpl_port                 = var.kpl_port
  log_level                = var.log_level
  replicas                 = var.replicas
  health_check             = var.health_check
  saml_role                = var.saml_role
  firehose_buffer_size     = var.firehose_buffer_size
  firehose_buffer_interval = var.firehose_buffer_interval
  deregistration_delay     = var.deregistration_delay
  tags                     = var.tags
  hosted_zone              = var.hosted_zone
  common_subdomain         = var.common_subdomain

  # region-specific variables
  environment_us_east_1                 = var.environment_us_east_1
  region_us_east_1                      = var.region_us_east_1
  vpc_us_east_1                         = var.vpc_us_east_1
  private_subnets_us_east_1             = var.private_subnets_us_east_1
  public_subnets_us_east_1              = var.public_subnets_us_east_1
  target_bucket_name_us_east_1          = var.target_bucket_name_us_east_1
  shard_count_us_east_1                 = var.shard_count_us_east_1
  environment_us_west_2                 = var.environment_us_west_2
  region_us_west_2                      = var.region_us_west_2
  vpc_us_west_2                         = var.vpc_us_west_2
  private_subnets_us_west_2             = var.private_subnets_us_west_2
  public_subnets_us_west_2              = var.public_subnets_us_west_2
  target_bucket_name_us_west_2          = var.target_bucket_name_us_west_2
  shard_count_us_west_2                 = var.shard_count_us_west_2
  common_environment                    = var.common_environment
  destination_region                    = var.destination_region
  ecs_autoscale_min_instances_us_east_1 = var.ecs_autoscale_min_instances_us_east_1
  ecs_autoscale_max_instances_us_east_1 = var.ecs_autoscale_max_instances_us_east_1
  ecs_autoscale_min_instances_us_west_2 = var.ecs_autoscale_min_instances_us_west_2
  ecs_autoscale_max_instances_us_west_2 = var.ecs_autoscale_max_instances_us_west_2
}

terraform {
  backend "s3" {
    region  = "us-east-1"
    profile = ""
    bucket  = "tf-state-${APP_NAME}-us-east-1"
    key     = "prod.modules.terraform.tfstate"
  }
}
