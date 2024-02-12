##############################################
# FLATCAR
##############################################

resource "aws_security_group" "flatcar" {
  name   = "Flatcar"
  vpc_id = aws_vpc.this.id
}

data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_vpc_security_group_ingress_rule" "cloudfront_to_flatcar" {
  description       = "HTTPS from CloudFront"
  security_group_id = aws_security_group.flatcar.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  prefix_list_id    = data.aws_ec2_managed_prefix_list.cloudfront.id
}

resource "aws_vpc_security_group_ingress_rule" "admin_to_flatcar" {
  count             = var.admin_ip != null ? 1 : 0
  description       = "Direct Access to Flatcar"
  security_group_id = aws_security_group.flatcar.id

  ip_protocol = "-1"
  cidr_ipv4   = var.admin_ip
}

resource "aws_vpc_security_group_egress_rule" "to_all" {
  description       = "Allow all egress"
  security_group_id = aws_security_group.flatcar.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

##############################################
# DATABASE
##############################################

resource "aws_security_group" "db" {
  name   = "Database"
  vpc_id = aws_vpc.this.id
}

resource "aws_vpc_security_group_ingress_rule" "flatcar_to_db" {
  description                  = "Database access from ECS Cluster"
  security_group_id            = aws_security_group.db.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.flatcar.id
}
