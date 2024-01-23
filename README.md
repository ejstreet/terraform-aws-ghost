# terraform-aws-ghost
Module for deploying a Ghost blog to AWS

The defaults will deploy an advanced deployment of Ghost, where all components are covered under the first 12 months of the AWS free-tier.

This includes:
- EC2 Instance running Flatcar Linux (t2/t3.micro)
  - Config to run the Ghost Docker container
  - EBS swap volume
- A separate RDS instance to host the database
- An Application Load Balancer
- ACM certificates for TLS

## DNS configuration 
Some additional configuration is required after running the module. The details are given as outputs.
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_ct"></a> [ct](#requirement\_ct) | ~> 0.13.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.0 |
| <a name="requirement_template"></a> [template](#requirement\_template) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.33.0 |
| <a name="provider_ct"></a> [ct](#provider\_ct) | 0.13.0 |
| <a name="provider_template"></a> [template](#provider\_template) | 2.2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ./vpc | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_db_instance.ghost](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_ebs_volume.swap](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_instance.flatcar](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_key_pair.ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_lb.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.ghost](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.ghost](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_security_group.securitygroup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.incoming_any](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.outgoing_any](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_volume_attachment.swap](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_ami.flatcar_stable_latest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ec2_instance_types.free_tier](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_instance_types) | data source |
| [ct_config.machine-ignitions](https://registry.terraform.io/providers/poseidon/ct/latest/docs/data-sources/config) | data source |
| [template_file.machine-configs](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region to use for running the machine | `string` | n/a | yes |
| <a name="input_db_password"></a> [db\_password](#input\_db\_password) | The password for accessing the database. It is recommended to pass this as an environment variable, e.g. `TF_VAR_db_password`. | `string` | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The fully qualified domain name used to access the website. Does not require a protocol prefix. | `string` | n/a | yes |
| <a name="input_ghost_image"></a> [ghost\_image](#input\_ghost\_image) | The image of Ghost to run. | `string` | n/a | yes |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | Name used for the instance | `string` | `"Ghost"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type for the machine. If unset, a free-tier instance will be used. | `string` | `null` | no |
| <a name="input_ssh_keys"></a> [ssh\_keys](#input\_ssh\_keys) | SSH public keys for user 'core' | `list(string)` | n/a | yes |
| <a name="input_subnet_cidrs"></a> [subnet\_cidrs](#input\_subnet\_cidrs) | n/a | `list(string)` | <pre>[<br>  "172.16.10.0/24",<br>  "172.16.20.0/24"<br>]</pre> | no |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | n/a | <pre>object({<br>    cidr                 = string<br>    public_cidrs         = list(string)<br>    public_ingress_rules = map(any)<br>    public_egress_rules  = map(any)<br>    private_cidrs        = list(string)<br>  })</pre> | <pre>{<br>  "cidr": "10.0.0.0/16",<br>  "private_cidrs": [<br>    "10.0.100.0/24",<br>    "10.0.102.0/24"<br>  ],<br>  "public_cidrs": [<br>    "10.0.0.0/24",<br>    "10.0.2.0/24"<br>  ],<br>  "public_egress_rules": {<br>    "Allow All": {<br>      "cidr_ipv4": "0.0.0.0/0"<br>    }<br>  },<br>  "public_ingress_rules": {<br>    "HTTP": {<br>      "cidr_ipv4": "0.0.0.0/0",<br>      "from_port": 80,<br>      "ip_protocol": "TCP"<br>    },<br>    "HTTPS": {<br>      "cidr_ipv4": "0.0.0.0/0",<br>      "from_port": 443,<br>      "ip_protocol": "TCP"<br>    }<br>  }<br>}</pre> | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | n/a | `string` | `"172.16.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_certificate_validation"></a> [certificate\_validation](#output\_certificate\_validation) | n/a |
| <a name="output_lb_domain_name"></a> [lb\_domain\_name](#output\_lb\_domain\_name) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
