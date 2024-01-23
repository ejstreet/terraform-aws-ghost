################################################################################
# Public Subnets
################################################################################

resource "aws_subnet" "public" {
  for_each = local.public_az_cidrs
  vpc_id   = aws_vpc.this.id

  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name                     = "${var.name}-subnet-public-${each.key}"
    security-tier            = "public"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_security_group" "public" {
  name   = "${var.name}-sg-public"
  vpc_id = aws_vpc.this.id

  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name          = "${var.name}-sg-public"
    security-tier = "public"
  }
}

resource "aws_vpc_security_group_ingress_rule" "public_from_private" {
  security_group_id            = aws_security_group.public.id
  referenced_security_group_id = aws_security_group.private.id

  ip_protocol = "-1"

  description = "Ingress from Private Subnet"
}

resource "aws_vpc_security_group_ingress_rule" "public_from_public" {
  security_group_id            = aws_security_group.public.id
  referenced_security_group_id = aws_security_group.public.id

  ip_protocol = "-1"

  description = "Ingress from Self"
}

resource "aws_vpc_security_group_egress_rule" "public_to_private" {
  security_group_id            = aws_security_group.public.id
  referenced_security_group_id = aws_security_group.private.id

  ip_protocol = "-1"

  description = "Egress to Private Subnet"
}

resource "aws_vpc_security_group_egress_rule" "public_to_public" {
  security_group_id            = aws_security_group.public.id
  referenced_security_group_id = aws_security_group.public.id

  ip_protocol = "-1"

  description = "Egress to Self"
}

resource "aws_vpc_security_group_ingress_rule" "public" {
  for_each          = var.public_ingress_rules
  security_group_id = aws_security_group.public.id

  cidr_ipv4   = each.value.cidr_ipv4
  from_port   = try(each.value.from_port, null)
  ip_protocol = try(each.value.ip_protocol, -1)
  to_port     = try(each.value.to_port, each.value.from_port, null)

  tags = {
    Name = each.key
  }

}

resource "aws_vpc_security_group_egress_rule" "public" {
  for_each          = var.public_egress_rules
  security_group_id = aws_security_group.public.id

  cidr_ipv4   = each.value.cidr_ipv4
  from_port   = try(each.value.from_port, null)
  ip_protocol = try(each.value.ip_protocol, -1)
  to_port     = try(each.value.to_port, each.value.from_port, null)

  description = each.key
}

resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public.id
  }

  tags = {
    Name = "${var.name}-rtb-public"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = toset(local.azs)
  subnet_id      = aws_subnet.public[each.value].id
  route_table_id = aws_route_table.public.id
}
