resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true

  tags = {
    Name = var.deployment_name
  }
}

# This fetches all the available AZs within a region because
# zone 'a' is not always necessarily available. We will then
# have to `slice()` this list to match the number of provided subnets
data "aws_availability_zones" "available" {}

# Here we take a list of the AZs, and map them to lists of provided
# subnet CIDRs. This is slightly overkill for the setup we're using,
# but gives an idea of how you might set up a VPC in a production environment
locals {
  azs = slice(data.aws_availability_zones.available.names, 0, length(var.private_cidrs))
  # We'll use the first AZ in the list to deploy our resources to
  target_az = local.azs[0]

  public_az_cidrs  = zipmap(local.azs, var.public_cidrs)
  private_az_cidrs = zipmap(local.azs, var.private_cidrs)
}

# PUBLIC SUBNET

# We create a subnet `for_each` CIDR in our `public_az_cidrs` map
resource "aws_subnet" "public" {
  for_each = local.public_az_cidrs
  vpc_id   = aws_vpc.this.id

  cidr_block        = each.value
  availability_zone = each.key

  enable_resource_name_dns_a_record_on_launch = true
  map_public_ip_on_launch                     = true

  tags = {
    Name          = "${var.deployment_name}-subnet-public-${each.key}"
    security-tier = "public"
  }
}

resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.deployment_name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public.id
  }

  tags = {
    Name        = "${var.deployment_name}-rtb-public"
    Description = "Default route table for public subnet"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = toset(local.azs)
  subnet_id      = aws_subnet.public[each.value].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${var.deployment_name}-rtb-private"
    Description = "Default route table for private subnet"
  }
}

# PRIVATE SUBNET

resource "aws_subnet" "private" {
  for_each = local.private_az_cidrs
  vpc_id   = aws_vpc.this.id

  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name          = "${var.deployment_name}-subnet-private-${each.key}"
    security-tier = "private"
  }
}

# Take the ids from the created private subnets, and feed them into a list
resource "aws_db_subnet_group" "private" {
  name       = lower("${var.deployment_name}-db-subnet-group-private")
  subnet_ids = [for k, subnet in aws_subnet.private : subnet.id]

  tags = {
    Name          = "${var.deployment_name}-db-subnet-group-private"
    security-tier = "private"
  }
}

resource "aws_route_table_association" "private" {
  for_each       = toset(local.azs)
  subnet_id      = aws_subnet.private[each.value].id
  route_table_id = aws_route_table.private.id
}
