resource "aws_key_pair" "ssh" {
  key_name   = var.instance_name
  public_key = var.ssh_keys[0]
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

  subnet_id              = local.target_subnet.id
  vpc_security_group_ids = [aws_security_group.flatcar.id]

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

    mail__from                      = aws_ses_email_identity.default.email
    mail__transport                 = "SMTP"
    mail__logger                    = "true"
    mail__options__host             = "email-smtp.${var.aws_region}.amazonaws.com"
    mail__options__port             = "465"
    mail__options__service          = "SES"
    mail__options__secureConnection = "true"
    mail__options__auth__user       = aws_iam_access_key.smtp_user.id
    mail__options__auth__pass       = aws_iam_access_key.smtp_user.ses_smtp_password_v4

    url = "https://${var.domain_name}"
  }
}

data "template_file" "machine-configs" {
  template = file("${path.module}/templates/flatcar.yaml.tmpl")

  vars = {
    ssh_keys    = jsonencode(var.ssh_keys)
    name        = var.instance_name
    ghost_image = var.ghost_image
    host        = var.domain_name
    env_vars    = join(" ", [for k, v in local.env_vars : "-e ${k}=${v}"])
  }
}
