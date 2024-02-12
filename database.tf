data "aws_rds_orderable_db_instance" "free-tier" {
  engine = "mysql"

  # The following are all eligible for free tier
  preferred_instance_classes = ["db.t4g.micro", "db.t3.micro", "db.t2.micro"]
}

locals {
  db_instance_class = data.aws_rds_orderable_db_instance.free-tier.instance_class
}

resource "aws_db_instance" "ghost" {
  allocated_storage = 20
  identifier        = lower(var.deployment_name)
  db_name           = "ghost"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = local.db_instance_class
  password          = var.db_password
  username          = "root"
  availability_zone = local.target_az

  iam_database_authentication_enabled = true

  db_subnet_group_name   = aws_db_subnet_group.private.name
  vpc_security_group_ids = [aws_security_group.db.id]

  apply_immediately   = true
  skip_final_snapshot = true
}
