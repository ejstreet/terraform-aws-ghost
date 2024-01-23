output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnets" {
  value = aws_subnet.public
}

output "public_security_group" {
  value = aws_security_group.public
}

output "private_security_group" {
  value = aws_security_group.private
}

output "private_subnets" {
  value = aws_subnet.private
}

output "db_subnet_group" {
  value = aws_db_subnet_group.private
}


