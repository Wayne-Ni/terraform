terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "terraform-tfstate-tset"
    key            = "dev/terraform.tfstate"
    region         = "ap-northeast-1"
  }
}

variable "aws_region" {
  type    = string
  default = "ap-northeast-1"
}

provider "aws" {
  region = var.aws_region
} 