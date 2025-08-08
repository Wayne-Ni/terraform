data "aws_ecr_repository" "app" {
  name = var.ecr_repo_name
}

data "aws_ecs_cluster" "app" {
  cluster_name = var.ecs_cluster_name
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.ecr_repo_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = jsonencode([
    {
      name      = "app"
      image     = "${data.aws_ecr_repository.app.repository_url}:${var.image_tag}"
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "app" {
  name            = var.ecs_service_name
  cluster         = data.aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = [aws_subnet.public.id]
    assign_public_ip = true
    security_groups = [aws_security_group.ecs.id]
  }
  depends_on = [aws_ecs_task_definition.app]
} 