

provider "aws" {
  region = var.aws_region
}

module "app" {
  source = "../modules/app"

  aws_region        = "ap-northeast-1"
  ecr_repo_name     = "myapp-dev"
  ecs_cluster_name  = "myapp-dev-cluster"
  ecs_service_name  = "myapp-dev-service"
  image_tag         = "dev-test"

  ssm_parameters = {
    DB_PASSWORD = "/myapp/dev/DB_PASSWORD"
  }  
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "ecr_repo_name" {
  description = "ECR repository name"
  type        = string
  default     = "myapp-dev"
}

variable "ecs_cluster_name" {
  description = "ECS cluster name"
  type        = string
  default     = "myapp-dev-cluster"
}

variable "ecs_service_name" {
  description = "ECS service name"
  type        = string
  default     = "myapp-dev-service"
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
}