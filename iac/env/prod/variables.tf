/*
 * variables.tf
 * Common variables to use in various Terraform files (*.tf)
 */

# The application's name
variable "app" {
}

variable "aws_profile" {
}


# Tags for the infrastructure
variable "tags" {
  type = map(string)
}

# Whether the application is available on the public internet,
# also will determine which subnets will be used (public or private)
variable "internal" {
  default = true
}

# The port the container will listen on, used for load balancer health check
# Best practice is that this value is higher than 1024 so the container processes
# isn't running at root.
variable "container_port" {
}

# The port the api will communicate with the kpl on
variable "kpl_port" {
}

# The verbosity of the logging.  debug, info, none
variable "log_level" {
}

# How many containers to run
variable "replicas" {
  default = "1"
}

# The path to the health check for the load balancer to know if the container(s) are ready
variable "health_check" {
}

# The SAML role to use for adding users to the ECR policy
variable "saml_role" {
}

variable "shard_count_us_east_1" {
  type    = number
  default = 1
}

variable "shard_count_us_west_2" {
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

variable "deregistration_delay" {
}

# Network configuration

# The VPC to use for the Fargate cluster
variable "vpc_us_east_1" {
}

variable "vpc_us_west_2" {
}

# The private subnets, minimum of 2, that are a part of the VPC(s)
variable "private_subnets_us_east_1" {
}

variable "private_subnets_us_west_2" {
}

# The public subnets, minimum of 2, that are a part of the VPC(s)
variable "public_subnets_us_east_1" {
}

variable "public_subnets_us_west_2" {
}

# The AWS region to use for the dev environment's infrastructure
variable "region_us_east_1" {
  default = "us-east-1"
}

variable "region_us_west_2" {
  default = "us-west-2"
}

# The common environment name
variable "common_environment" {
}

# The destination environment
variable "environment_us_east_1" {
}

# The source environment
variable "environment_us_west_2" {
}

# the target bucket for the destination
variable "target_bucket_name_us_east_1" {
}

# the target bucket for the source
variable "target_bucket_name_us_west_2" {
}

# the min and max instances for the auto scaling
variable "ecs_autoscale_min_instances_us_east_1" {
}

variable "ecs_autoscale_max_instances_us_east_1" {
}

variable "ecs_autoscale_min_instances_us_west_2" {
}

variable "ecs_autoscale_max_instances_us_west_2" {
}

locals {
  nsuseast1 = "${var.app}-${var.environment_us_east_1}"
  nsuswest2 = "${var.app}-${var.environment_us_west_2}"
}

variable "hosted_zone" {
}

variable "common_subdomain" {
}

# The destination buckets region
variable "destination_region" {
}
