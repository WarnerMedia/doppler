# _provider.tf
provider "aws" {
  region  = "us-east-1"
  profile = var.aws_profile
}
