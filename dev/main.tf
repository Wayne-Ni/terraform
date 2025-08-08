module "app" {
  source = "../modules/app"

  aws_region        = "ap-northeast-1"
  ecr_repo_name     = "myapp-dev"
  ecs_cluster_name  = "myapp-dev-cluster"
  ecs_service_name  = "myapp-dev-service"
  image_tag         = var.image_tag
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
} 