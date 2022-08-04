# _provider.tf
provider "aws" {
  region  = "us-east-1"
  profile = var.aws_profile
}

provider "aws" {
  alias   = "us-west-2"
  region  = "us-west-2"
  profile = var.aws_profile
}
