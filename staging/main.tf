terraform {
  backend "s3" {}
}

data "aws_caller_identity" "current" {}

locals {
  repo            = "myapp-staging"
  repository_url  = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${local.repo}"
}

module "app" {
  source         = "../modules/app"
  repository_url = local.repository_url
  cluster_name   = "myapp-staging-cluster"
  service_name   = "myapp-staging-service"
  image_tag      = var.image_tag
  secrets        = var.secrets
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
}

variable "secrets" {
  description = "Map of env var -> SSM parameter name/ARN or Secrets Manager ARN"
  type        = map(string)
  default = {
    DB_PASSWORD = "/myapp/staging/DB_PASSWORD"
  }
}