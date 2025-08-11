data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

module "ecs_app_app1" {
  source               = "../modules/ecs_app"
  repository_url       = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecs_apps["app1"].repo}"
  cluster_name         = var.ecs_apps["app1"].cluster_name
  service_name         = var.ecs_apps["app1"].service_name
  image_tag            = var.ecs_apps["app1"].image_tag
  secrets              = lookup(var.ecs_apps["app1"], "secrets", {})
}

module "ecs_app_app2" {
  source               = "../modules/ecs_app"
  repository_url       = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecs_apps["app2"].repo}"
  cluster_name         = var.ecs_apps["app2"].cluster_name
  service_name         = var.ecs_apps["app2"].service_name
  image_tag            = var.ecs_apps["app2"].image_tag
  secrets              = lookup(var.ecs_apps["app2"], "secrets", {})
}

