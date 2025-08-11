variable "vpc_id" {
  description = "VPC id"
  type        = string
}

resource "aws_security_group" "ecs" {
  name        = "ecs-sg"
  description = "Allow 8080 inbound"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "sg_id" {
  value = aws_security_group.ecs.id
} 