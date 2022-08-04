/*
 * variables.tf
 * Common variables to use in various Terraform files (*.tf)
 */

# The application's name
variable "app" {
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

variable "deregistration_delay" {
}

# Network configuration

# The VPC to use for the Fargate cluster
variable "vpc" {
}

# The private subnets, minimum of 2, that are a part of the VPC(s)
variable "private_subnets" {
}

# The public subnets, minimum of 2, that are a part of the VPC(s)
variable "public_subnets" {
}

# The AWS region to use for the dev environment's infrastructure
variable "region" {
}

# The environment that is being built
variable "environment" {
}

# the target bucket
variable "target_bucket_name" {
}

locals {
  ns = "${var.app}-${var.environment}"
}

variable "route53_zone_id" {
}

variable "hosted_zone" {
}

variable "common_subdomain" {
}

variable "identity_domain" {
}

variable "identity_zone_id" {
}

variable "telemetry_domain" {
}

variable "telemetry_zone_id" {
}

variable "ecs_autoscale_min_instances" {
}

variable "ecs_autoscale_max_instances" {
}
