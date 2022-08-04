/*
 * variables.tf
 * Common variables to use in various Terraform files (*.tf)
 */

# The AWS region to use for the environment's infrastructure
variable "region" {
}

# Tags for the infrastructure
variable "tags" {
  type = map(string)
}

# The application's name
variable "app" {
}

# The environment that is being built
variable "environment" {
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
# The port the load balancer will listen on
variable "lb_port" {
  default = "80"
}

# The load balancer protocol
variable "lb_protocol" {
  default = "HTTP"
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

# How many containers to run
variable "replicas" {
  default = "1"
}

# The name of the container to run
variable "container_name" {
  default = "app"
}

# The minimum number of containers that should be running.
# Must be at least 1.
# used by both autoscale-perf.tf and autoscale.time.tf
# For production, consider using at least "2".
variable "ecs_autoscale_min_instances" {
  default = "1"
}

# The maximum number of containers that should be running.
# used by both autoscale-perf.tf and autoscale.time.tf
variable "ecs_autoscale_max_instances" {
  default = "8"
}

variable "logs_retention_in_days" {
  type        = number
  default     = 90
  description = "Specifies the number of days you want to retain log events"
}

locals {
  ns = "${var.app}-${var.environment}"
}

# these are passed in from a parent module
# The parent module must create an S3 bucket with KMS and pass the buckets arn via s3_target_bucket_arn and the buckets id via s3_target_bucket_id.
# The arn of the KMS key for the bucket must be passed in via s3_target_bucket_kms_arn
variable "s3_target_bucket_arn" {
}

variable "s3_target_bucket_id" {
}

variable "s3_target_bucket_kms_arn" {
}

# these are passed in from a parent module
# The parent module must have already created the common_subdomain(ex. dev.${DOMAIN_NAME}) in the hosted_zone(${DOMAIN_NAME}).
# The route53_zone_id is the zone id of the hosted_zone.
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

# If the average CPU utilization over a minute drops to this threshold,
# the number of containers will be reduced (but not below ecs_autoscale_min_instances).
variable "ecs_as_cpu_low_threshold_per" {
  default = "20"
}

# If the average CPU utilization over a minute rises to this threshold,
# the number of containers will be increased (but not above ecs_autoscale_max_instances).
variable "ecs_as_cpu_high_threshold_per" {
  default = "60"
}
