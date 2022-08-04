/*
 * ecr.tf
 * Creates a Amazon Elastic Container Registry (ECR) for the application
 * https://aws.amazon.com/ecr/
 */

resource "aws_ecr_repository" "app" {
  name                 = var.app
  image_tag_mutability = var.image_tag_mutability
}
