resource "aws_cloudwatch_log_group" "app" {
  name              = coalesce(var.log_group_name, "/ecs/${var.ecr_repo_name}")
  retention_in_days = var.log_retention_days
}


