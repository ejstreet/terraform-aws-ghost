resource "aws_key_pair" "ssh" {
  key_name   = var.deployment_name
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

locals {
  env_vars = merge({
    database__client               = "mysql",
    database__connection__database = "ghost",
    database__connection__user     = "root",
    database__connection__host     = aws_db_instance.ghost.address,
    database__connection__password = var.db_password
    # The built in CA for RDS has expired, a workaround is needed to get this to work properly https://github.com/TryGhost/Ghost/issues/19462
    # database__connection__ssl      = "Amazon RDS"

    url = "https://${var.domain_name}"
  }, var.ghost_extra_env_vars)
}

data "template_file" "machine-configs" {
  template = file("${path.module}/templates/flatcar.yaml.tmpl")

  vars = {
    ssh_keys          = jsonencode(var.ssh_keys)
    name              = var.deployment_name
    ghost_image       = var.ghost_image
    env_vars          = join(" ", [for k, v in local.env_vars : "-e ${k}='${v}'"])
    mount_device_name = local.persistent_data_device_name
    nginx_config      = indent(10, data.template_file.nginx-config.rendered)
  }
}

data "ct_config" "machine-ignitions" {
  content = data.template_file.machine-configs.rendered
}

data "template_file" "nginx-config" {
  template = file("${path.module}/templates/nginx.conf.tmpl")

  vars = {
    host = var.domain_name
  }
}

resource "aws_instance" "flatcar" {
  instance_type = local.instance_type
  user_data     = data.ct_config.machine-ignitions.rendered
  ami           = data.aws_ami.flatcar_stable_latest.image_id
  key_name      = aws_key_pair.ssh.key_name

  subnet_id              = aws_subnet.public[local.target_az].id
  vpc_security_group_ids = [aws_security_group.flatcar.id]

  tags = {
    Name = var.deployment_name
  }

  user_data_replace_on_change = true
}

resource "aws_ebs_volume" "persistent-data" {
  availability_zone = local.target_az
  size              = 20

  tags = {
    Name = "flatcar-persistent-data"
  }
}

locals {
  persistent_data_device_name = "/dev/xvdf"
}

resource "aws_volume_attachment" "persistent-data" {
  device_name = local.persistent_data_device_name
  volume_id   = aws_ebs_volume.persistent-data.id
  instance_id = aws_instance.flatcar.id

  # Adding this option prevents terraform from detaching the volume while
  # the instance is still running. Terminating the instance detaches the volume
  skip_destroy = true
}
