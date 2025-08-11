variable "execution_role_arn" { type = string }
variable "container_image"   { type = string }
variable "subnet_ids"        { type = list(string) }
variable "security_group_ids"{ type = list(string) }
variable "cluster_name"      { type = string }
variable "service_name"      { type = string }
variable "secrets" {
  description = "Map of env var name to SSM parameter name/ARN or Secrets Manager ARN"
  type        = map(string)
  default     = {}
}

# 取得目前 AWS Region 供 logs driver 使用
data "aws_region" "current" {}

# 建立 CloudWatch Logs 群組
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.service_name}"
  retention_in_days = 30
}

resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.service_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.execution_role_arn
  container_definitions = jsonencode([
    {
      name      = "app"
      image     = var.container_image
      essential = true
      portMappings = [{ containerPort = 8080, hostPort = 8080 }]
      secrets = [for k, v in var.secrets : { name = k, valueFrom = v }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "app"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "this" {
  name                  = var.service_name
  cluster               = aws_ecs_cluster.this.id
  task_definition       = aws_ecs_task_definition.this.arn
  desired_count         = 1
  launch_type           = "FARGATE"
  wait_for_steady_state = true
  timeouts {
    create = "5m"
    update = "5m"
    delete = "5m"
  }
  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = true
  }
  depends_on = [aws_ecs_task_definition.this]
}

output "cluster_arn" {
  value = aws_ecs_cluster.this.arn
}

output "service_name" {
  value = aws_ecs_service.this.name
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.this.arn
} 