locals {
  use_data_ecr = var.create_ecr_repository == false
}

resource "aws_ecr_repository" "app" {
  count = var.create_ecr_repository ? 1 : 0
  name  = var.ecr_repo_name
}

data "aws_ecr_repository" "app" {
  count = local.use_data_ecr ? 1 : 0
  name  = var.ecr_repo_name
}

locals {
  ecr_repository_url = var.create_ecr_repository ? aws_ecr_repository.app[0].repository_url : data.aws_ecr_repository.app[0].repository_url
}


