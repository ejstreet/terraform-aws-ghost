resource "aws_db_instance" "ghost" {
  allocated_storage = 20
  identifier        = lower(var.instance_name)
  db_name           = "ghost"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  password          = var.db_password
  username          = "root"

  db_subnet_group_name   = module.vpc.db_subnet_group.name
  vpc_security_group_ids = [module.vpc.private_security_group.id]

  apply_immediately   = true
  skip_final_snapshot = true
}
