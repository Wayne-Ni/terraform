output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "ecs_task_definition_arn" {
  value = aws_ecs_task_definition.app.arn
}

output "ecs_service_name" {
  value = aws_ecs_service.app.name
} 