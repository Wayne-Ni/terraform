variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "ecr_repo_name" {
  description = "ECR repository name"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "ecs_service_name" {
  description = "ECS service name"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR block"
  type        = string
  default     = "10.0.1.0/24"
}

variable "container_env_vars" {
  description = "Non-sensitive environment variables for the container (KEY => VALUE)"
  type        = map(string)
  default     = {}
}

variable "ssm_parameters" {
  description = "Map of environment variable name to SSM Parameter name (with path). Values are fetched and injected via ECS secrets."
  type        = map(string)
  default     = {}
}

variable "required_ssm_vars" {
  description = "List of SSM-backed env var names that are mandatory. Apply will fail if any are missing from ssm_parameters."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for k in var.required_ssm_vars : contains(keys(var.ssm_parameters), k)])
    error_message = "One or more required_ssm_vars are missing from ssm_parameters."
  }
}

variable "create_ecr_repository" {
  description = "Whether to create the ECR repository if it does not exist"
  type        = bool
  default     = true
}

variable "create_ecs_cluster" {
  description = "Whether to create the ECS cluster if it does not exist"
  type        = bool
  default     = true
}

variable "log_group_name" {
  description = "CloudWatch Logs group name for the container. Leave empty to use default /ecs/<ecr_repo_name>"
  type        = string
  default     = ""
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention in days"
  type        = number
  default     = 7
}


