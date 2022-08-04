terraform {
  required_version = "= 0.14.5"

  backend "s3" {
    region  = "us-west-2"
    profile = ""
    bucket  = "tf-state-doppler-${APP_NAME}-global"
    key     = "prod.terraform.tfstate"
  }
}

# The AWS Profile to use
variable "aws_profile" {
}

provider "aws" {
  region  = "us-west-2"
  profile = var.aws_profile
}
