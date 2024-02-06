terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

################################################################################
# VPC Module
################################################################################

data "aws_availability_zones" "available" {}

locals {
  azs              = slice(data.aws_availability_zones.available.names, 0, length(var.private_cidrs))
  public_az_cidrs  = zipmap(local.azs, var.public_cidrs)
  private_az_cidrs = zipmap(local.azs, var.private_cidrs)
}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.name}-VPC"
  }
}
