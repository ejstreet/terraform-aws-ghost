module "vpc" {
  source = "./vpc"

  name = var.deployment_name

  vpc_cidr = var.vpc.cidr

  public_cidrs  = var.vpc.public_cidrs
  private_cidrs = var.vpc.private_cidrs

  public_ingress_rules = var.vpc.public_ingress_rules
  public_egress_rules  = var.vpc.public_egress_rules
}
