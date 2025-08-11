resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# 允許從 SSM Parameter Store 與 Secrets Manager 讀取機密（可視需要改為資源級別授權）
resource "aws_iam_role_policy" "ecs_execution_read_secrets" {
  name = "ecsExecutionReadSecrets"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter",
          "secretsmanager:GetSecretValue",
          "kms:Decrypt"
        ],
        Resource = "*"
      }
    ]
  })
}

output "execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
} 