output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "security_group_id" {
  value = aws_security_group.ecs.id
}

output "ecr_repository_url" {
  value = local.ecr_repository_url
}

output "ecs_task_definition_arn" {
  value = aws_ecs_task_definition.app.arn
}

output "ecs_service_name" {
  value = aws_ecs_service.app.name
}


