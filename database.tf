data "aws_rds_orderable_db_instance" "free-tier" {
  engine         = "mysql"
  engine_version = "8.0"

  # The following are all available under the free tier
  preferred_instance_classes = ["db.t4g.micro", "db.t3.micro", "db.t2.micro"]
}

locals {
  db_instance_class = aws_rds_orderable_db_instance.free-tier.instance_class
}

resource "aws_db_instance" "ghost" {
  allocated_storage = 20
  identifier        = lower(var.instance_name)
  db_name           = "ghost"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = local.db_instance_class
  password          = var.db_password
  username          = "root"
  availability_zone = local.target_az

  db_subnet_group_name   = module.vpc.db_subnet_group.name
  vpc_security_group_ids = [module.vpc.private_security_group.id]

  apply_immediately   = true
  skip_final_snapshot = true
}
