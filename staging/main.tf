terraform {
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

module "app" {
  source = "../modules/app"

  aws_region        = var.aws_region
  ecr_repo_name     = var.ecr_repo_name
  ecs_cluster_name  = var.ecs_cluster_name
  ecs_service_name  = var.ecs_service_name
  image_tag         = var.image_tag
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "ecr_repo_name" {
  description = "ECR repository name"
  type        = string
  default     = "myapp-staging"
}

variable "ecs_cluster_name" {
  description = "ECS cluster name"
  type        = string
  default     = "myapp-staging-cluster"
}

variable "ecs_service_name" {
  description = "ECS service name"
  type        = string
  default     = "myapp-staging-service"
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
}