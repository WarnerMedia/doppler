# app/env to scaffold
# common variables in all environments
app                      = "${APP_NAME}"
aws_profile              = ""
internal                 = false
container_port           = 8080
kpl_port                 = 3000
log_level                = "info"
replicas                 = "1"
health_check             = "/health"
saml_role                = ""
common_subdomain         = "${DOMAIN_NAME}"
hosted_zone              = "${DOMAIN_NAME}"
firehose_buffer_size     = 64
firehose_buffer_interval = 300
deregistration_delay     = 10
tags = {
  application   = "${APP_NAME}"
  customer      = ""
  contact-email = ""
  environment   = "prod"
  team          = ""
}
common_environment = "prod"
destination_region = "us-east-1"

# variables that differ in each environment
# us-east-1
environment_us_east_1                 = "produseast1"
region_us_east_1                      = "us-east-1"
vpc_us_east_1                         = ""
private_subnets_us_east_1             = ""
public_subnets_us_east_1              = ""
target_bucket_name_us_east_1          = "${APP_NAME}-useast1"
ecs_autoscale_min_instances_us_east_1 = 1
ecs_autoscale_max_instances_us_east_1 = 1
shard_count_us_east_1                 = 1
# us-west-2
environment_us_west_2                 = "produswest2"
region_us_west_2                      = "us-west-2"
vpc_us_west_2                         = ""
private_subnets_us_west_2             = ""
public_subnets_us_west_2              = ""
target_bucket_name_us_west_2          = "${APP_NAME}-uswest2"
ecs_autoscale_min_instances_us_west_2 = 1
ecs_autoscale_max_instances_us_west_2 = 1
shard_count_us_west_2                 = 1
