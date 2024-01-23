################################################################################
# Private Subnets
# - Can only connect to resources in Public subnets, no ingress or egress from 
# the internet is permitted
################################################################################


resource "aws_subnet" "private" {
  for_each = local.private_az_cidrs
  vpc_id   = aws_vpc.this.id

  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name          = "${var.name}-subnet-private-${each.key}"
    security-tier = "private"
  }
}

resource "aws_security_group" "private" {
  name   = "${var.name}-sg-private"
  vpc_id = aws_vpc.this.id

  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name          = "${var.name}-sg-private"
    security-tier = "private"
  }
}

resource "aws_db_subnet_group" "private" {
  name       = lower("${var.name}-db-subnet-group-private")
  subnet_ids = [for k, subnet in aws_subnet.private : subnet.id]

  tags = {
    Name          = "${var.name}-db-subnet-group-private"
    security-tier = "private"
  }
}

resource "aws_vpc_security_group_ingress_rule" "private_from_public" {
  security_group_id            = aws_security_group.private.id
  referenced_security_group_id = aws_security_group.public.id

  ip_protocol = "-1"

  description = "Ingress from Public Subnet"
}

resource "aws_vpc_security_group_egress_rule" "private_to_public" {
  security_group_id            = aws_security_group.private.id
  referenced_security_group_id = aws_security_group.public.id

  ip_protocol = "-1"

  description = "Egress to Public Subnet"
}

resource "aws_vpc_security_group_ingress_rule" "private" {
  for_each          = var.private_ingress_rules
  security_group_id = aws_security_group.private.id

  cidr_ipv4   = each.value.cidr_ipv4
  from_port   = try(each.value.from_port, null)
  ip_protocol = try(each.value.ip_protocol, -1)
  to_port     = try(each.value.to_port, each.value.from_port, null)

  description = each.key
}

resource "aws_vpc_security_group_egress_rule" "private" {
  for_each          = var.private_egress_rules
  security_group_id = aws_security_group.private.id

  cidr_ipv4   = each.value.cidr_ipv4
  from_port   = try(each.value.from_port, null)
  ip_protocol = try(each.value.ip_protocol, -1)
  to_port     = try(each.value.to_port, each.value.from_port, null)

  description = each.key
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${var.name}-rtb-private"
    Description = "Default route table for private subnet"
  }
}

resource "aws_route_table_association" "private" {
  for_each       = toset(local.azs)
  subnet_id      = aws_subnet.private[each.value].id
  route_table_id = aws_route_table.private.id
}
