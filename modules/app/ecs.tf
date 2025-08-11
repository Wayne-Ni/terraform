locals {
  use_data_cluster = var.create_ecs_cluster == false
}

resource "aws_ecs_cluster" "app" {
  count = var.create_ecs_cluster ? 1 : 0
  name  = var.ecs_cluster_name
}

data "aws_ecs_cluster" "app" {
  count        = local.use_data_cluster ? 1 : 0
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
      image     = "${local.ecr_repository_url}:${var.image_tag}"
      essential = true
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = coalesce(var.log_group_name, "/ecs/${var.ecr_repo_name}")
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
      environment = [
        for k, v in var.container_env_vars : {
          name  = k
          value = v
        }
      ]
      secrets = [
        for name, param in var.ssm_parameters : {
          name      = name
          valueFrom = data.aws_ssm_parameter.app_params[name].arn
        }
      ]
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
  cluster         = var.create_ecs_cluster ? aws_ecs_cluster.app[0].id : data.aws_ecs_cluster.app[0].id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [aws_subnet.public.id]
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs.id]
  }
  wait_for_steady_state = true

  timeouts {
    create = "20m"
    update = "20m"
    delete = "20m"
  }
  depends_on = [aws_ecs_task_definition.app]
}


