variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "repository_url" {
  description = "ECR repository URL (e.g., 123456789012.dkr.ecr.ap-northeast-1.amazonaws.com/myapp-dev)"
  type        = string
}

variable "cluster_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "image_tag" {
  type = string
}

variable "secrets" {
  description = "Map of env var -> SSM parameter name/ARN or Secrets Manager ARN"
  type        = map(string)
  default     = {}
}

variable "allowed_ssm_parameters" {
  description = "List of SSM parameter ARNs or names the execution role can read. Use full ARNs for best practice. Leave empty to allow * (not recommended for prod)."
  type        = list(string)
  default     = []
}

variable "allowed_secretsmanager_arns" {
  description = "List of Secrets Manager secret ARNs the execution role can read. Leave empty to allow * (not recommended for prod)."
  type        = list(string)
  default     = []
}

variable "allowed_kms_keys" {
  description = "List of KMS Key ARNs allowed for decrypt when reading SSM/Secrets. Leave empty to allow * (not recommended for prod)."
  type        = list(string)
  default     = []
}

module "vpc" {
  source             = "../vpc"
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
}

module "sg" {
  source = "../sg"
  vpc_id = module.vpc.vpc_id
}

# 使用通用 IAM 模組建立每個服務的 Execution Role
locals {
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = "sts:AssumeRole",
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })

  ssm_resources     = length(var.allowed_ssm_parameters) > 0 ? var.allowed_ssm_parameters : ["*"]
  secrets_resources = length(var.allowed_secretsmanager_arns) > 0 ? var.allowed_secretsmanager_arns : ["*"]
  kms_resources     = length(var.allowed_kms_keys) > 0 ? var.allowed_kms_keys : ["*"]

  inline_read_secrets = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "ssm:GetParameters",
        "ssm:GetParameter",
        "secretsmanager:GetSecretValue",
        "kms:Decrypt"
      ],
      Resource = concat(local.ssm_resources, local.secrets_resources, local.kms_resources)
    }]
  })
}

module "exec_role" {
  source                   = "../iam_role"
  role_name                = "${var.service_name}-exec"
  assume_role_policy_json  = local.assume_role_policy
  attached_policy_arns     = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
  inline_policies = {
    read_secrets = local.inline_read_secrets
  }
}

locals {
  container_image = "${var.repository_url}:${var.image_tag}"
}

module "ecs" {
  source             = "../ecs"
  execution_role_arn = module.exec_role.arn
  container_image    = local.container_image
  subnet_ids         = [module.vpc.public_subnet_id]
  security_group_ids = [module.sg.sg_id]
  cluster_name       = var.cluster_name
  service_name       = var.service_name
  secrets            = var.secrets
}

output "ecs_task_definition_arn" {
  value = module.ecs.task_definition_arn
}

output "ecs_service_name" {
  value = module.ecs.service_name
}

output "vpc_id" {
  value = module.vpc.vpc_id
} 