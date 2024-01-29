resource "aws_key_pair" "ssh" {
  key_name   = var.instance_name
  public_key = var.ssh_keys.0
}

data "aws_ec2_instance_types" "free_tier" {
  filter {
    name   = "free-tier-eligible"
    values = ["true"]
  }
}

locals {
  instance_type = var.instance_type != null ? var.instance_type : data.aws_ec2_instance_types.free_tier.instance_types[0]
  target_subnet = module.vpc.public_subnets[keys(module.vpc.public_subnets)[0]]
  target_az     = local.target_subnet.availability_zone
}

data "aws_ami" "flatcar_stable_latest" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["Flatcar-stable-*"]
  }
}

resource "aws_instance" "flatcar" {
  instance_type = local.instance_type
  user_data     = data.ct_config.machine-ignitions.rendered
  ami           = data.aws_ami.flatcar_stable_latest.image_id
  key_name      = aws_key_pair.ssh.key_name

  associate_public_ip_address = true
  subnet_id                   = local.target_subnet.id
  vpc_security_group_ids      = [module.vpc.public_security_group.id]

  tags = {
    Name = var.instance_name
  }

  user_data_replace_on_change = true

  lifecycle {
    ignore_changes = [
      ami,
    ]
  }
}

resource "aws_ebs_volume" "swap" {
  availability_zone = aws_instance.flatcar.availability_zone
  size              = 8

  type = "gp3"

  tags = {
    Name = "${var.instance_name}-swap"
  }
}

resource "aws_volume_attachment" "swap" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.swap.id
  instance_id = aws_instance.flatcar.id
}

data "ct_config" "machine-ignitions" {
  content = data.template_file.machine-configs.rendered
}

locals {
  env_vars = {
    database__client               = "mysql",
    database__connection__database = "ghost",
    database__connection__user     = "root",
    database__connection__host     = aws_db_instance.ghost.address,
    database__connection__password = var.db_password
    url                            = "https://${var.domain_name}"
  }
}

data "template_file" "machine-configs" {
  template = file("${path.module}/templates/flatcar.yaml.tmpl")

  vars = {
    ssh_keys    = jsonencode(var.ssh_keys)
    name        = var.instance_name
    ghost_image = var.ghost_image
    env_vars    = "-e ${join(" -e ", [for k, v in local.env_vars : "${k}=${v}"])}"
  }
}

resource "aws_security_group" "securitygroup" {
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "outgoing_any" {
  security_group_id = aws_security_group.securitygroup.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "incoming_any" {
  security_group_id = aws_security_group.securitygroup.id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_lb" "public" {
  name               = var.instance_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.vpc.public_security_group.id]
  subnets            = [for subnet in module.vpc.public_subnets : subnet.id]
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.public.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ghost.arn
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.public.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group" "ghost" {
  name     = var.instance_name
  port     = 8080
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    protocol = "HTTP"
    matcher  = 301
    path     = "/ghost/api/admin/site/"
  }
}

resource "aws_lb_target_group_attachment" "ghost" {
  target_group_arn = aws_lb_target_group.ghost.arn
  target_id        = aws_instance.flatcar.id
  port             = 8080
}

resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = {
    Name = var.instance_name
  }

  lifecycle {
    create_before_destroy = true
  }
}