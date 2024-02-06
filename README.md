# terraform-aws-ghost
Module for deploying a Ghost blog to AWS

The defaults will deploy an advanced deployment of Ghost, where all components are covered under the first 12 months of the AWS free-tier.

This includes:
- A VPC with a public and private subnets
- EC2 Instance running Flatcar Linux (`t2`/`t3.micro`)
  - Config to run the Ghost Docker container
  - EBS swap volume
- A separate RDS instance to host the database (`db.t3.micro`)
- An Application Load Balancer
- ACM certificates for TLS
- A Cloudfront CDN

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.35.0 |
| <a name="provider_aws.global"></a> [aws.global](#provider\_aws.global) | 5.35.0 |
| <a name="provider_ct"></a> [ct](#provider\_ct) | 0.13.0 |
| <a name="provider_template"></a> [template](#provider\_template) | 2.2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ./vpc | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.cdn_cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_cloudfront_distribution.ghost](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_db_instance.ghost](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_instance.flatcar](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_key_pair.ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_security_group.db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.flatcar](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.to_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.admin_to_flatcar](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.cloudfront_to_flatcar](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.flatcar_to_db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_ami.flatcar_stable_latest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_cloudfront_cache_policy.caching-optimized](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_cache_policy) | data source |
| [aws_cloudfront_cache_policy.disabled](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_cache_policy) | data source |
| [aws_cloudfront_origin_request_policy.all-viewer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_origin_request_policy) | data source |
| [aws_cloudfront_response_headers_policy.simple-cors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_response_headers_policy) | data source |
| [aws_ec2_instance_types.free_tier](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_instance_types) | data source |
| [aws_ec2_managed_prefix_list.cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_managed_prefix_list) | data source |
| [aws_rds_orderable_db_instance.free-tier](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/rds_orderable_db_instance) | data source |
| [ct_config.machine-ignitions](https://registry.terraform.io/providers/poseidon/ct/latest/docs/data-sources/config) | data source |
| [template_file.machine-configs](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_ip"></a> [admin\_ip](#input\_admin\_ip) | IP address with subnet mask (ideally `/32`) of admin to allow direct access to the instance. Only creates security group rule if set. | `string` | `null` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region to use for running the machine | `string` | n/a | yes |
| <a name="input_db_password"></a> [db\_password](#input\_db\_password) | The password for accessing the database. It is recommended to pass this as an environment variable, e.g. `TF_VAR_db_password`. | `string` | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The fully qualified domain name used to access the website. Does not require a protocol prefix. | `string` | n/a | yes |
| <a name="input_ghost_image"></a> [ghost\_image](#input\_ghost\_image) | The image of Ghost to run. | `string` | n/a | yes |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | Name used for the instance | `string` | `"Ghost"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type for the machine. If unset, a free-tier instance will be used. | `string` | `null` | no |
| <a name="input_ssh_keys"></a> [ssh\_keys](#input\_ssh\_keys) | SSH public keys for user 'core' | `list(string)` | n/a | yes |
| <a name="input_uncached_paths"></a> [uncached\_paths](#input\_uncached\_paths) | n/a | `list(string)` | <pre>[<br>  "/ghost/*",<br>  "/members/*"<br>]</pre> | no |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | n/a | <pre>object({<br>    cidr                 = string<br>    public_cidrs         = list(string)<br>    public_ingress_rules = map(any)<br>    public_egress_rules  = map(any)<br>    private_cidrs        = list(string)<br>  })</pre> | <pre>{<br>  "cidr": "10.0.0.0/16",<br>  "private_cidrs": [<br>    "10.0.100.0/24",<br>    "10.0.102.0/24"<br>  ],<br>  "public_cidrs": [<br>    "10.0.0.0/24",<br>    "10.0.2.0/24"<br>  ],<br>  "public_egress_rules": {<br>    "Allow All": {<br>      "cidr_ipv4": "0.0.0.0/0"<br>    }<br>  },<br>  "public_ingress_rules": {<br>    "HTTP": {<br>      "cidr_ipv4": "0.0.0.0/0",<br>      "from_port": 80,<br>      "ip_protocol": "TCP"<br>    },<br>    "HTTPS": {<br>      "cidr_ipv4": "0.0.0.0/0",<br>      "from_port": 443,<br>      "ip_protocol": "TCP"<br>    }<br>  }<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cdn_certificate_validation"></a> [cdn\_certificate\_validation](#output\_cdn\_certificate\_validation) | n/a |
| <a name="output_cdn_domain_name"></a> [cdn\_domain\_name](#output\_cdn\_domain\_name) | n/a |
| <a name="output_ec2_ip"></a> [ec2\_ip](#output\_ec2\_ip) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
