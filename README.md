# terraform-aws-ghost
Module for deploying a Ghost blog to AWS

The defaults will deploy an fully featured deployment of Ghost, where all components are covered under the first 12 months of the AWS free-tier.

This includes:
- A VPC with a public and private subnets
- EC2 Instance running Flatcar Linux (`t2`/`t3.micro`)
  - Configuration to run Ghost and Nginx Docker containers
  - EBS persistent volume
  - Security groups to prevent direct access to the instance
- A separate RDS instance to host the database (`db.`(`t4g`/`t3`/`t2`)`.micro`)
- A Cloudfront CDN
- ACM certificates for TLS


## DNS configuration 
Some additional configuration is required after running the module. The details are given as outputs. You can either enter these into your DNS provider manually, or use this module in a larger terraform deployment that creates the DNS records.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_ct"></a> [ct](#requirement\_ct) | ~> 0.13.0 |
| <a name="requirement_template"></a> [template](#requirement\_template) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.36.0 |
| <a name="provider_aws.global"></a> [aws.global](#provider\_aws.global) | 5.36.0 |
| <a name="provider_ct"></a> [ct](#provider\_ct) | 0.13.0 |
| <a name="provider_template"></a> [template](#provider\_template) | 2.2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.cdn_cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_cloudfront_cache_policy.caching-optimized-with-ghost-cookies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_cache_policy) | resource |
| [aws_cloudfront_distribution.ghost](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_db_instance.ghost](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_ebs_volume.persistent-data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_instance.flatcar](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_internet_gateway.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_key_pair.ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.flatcar](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_volume_attachment.persistent-data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_security_group_egress_rule.to_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.admin_to_flatcar](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.cloudfront_to_flatcar](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.flatcar_to_db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_ami.flatcar_stable_latest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_cloudfront_cache_policy.disabled](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_cache_policy) | data source |
| [aws_cloudfront_cache_policy.optimized](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_cache_policy) | data source |
| [aws_cloudfront_origin_request_policy.all-viewer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_origin_request_policy) | data source |
| [aws_cloudfront_response_headers_policy.simple-cors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_response_headers_policy) | data source |
| [aws_ec2_instance_types.free_tier](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_instance_types) | data source |
| [aws_ec2_managed_prefix_list.cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_managed_prefix_list) | data source |
| [aws_rds_orderable_db_instance.free-tier](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/rds_orderable_db_instance) | data source |
| [ct_config.machine-ignitions](https://registry.terraform.io/providers/poseidon/ct/latest/docs/data-sources/config) | data source |
| [template_file.machine-configs](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.nginx-config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_ip"></a> [admin\_ip](#input\_admin\_ip) | IP address with subnet mask (ideally `/32`) of admin to allow direct access to the instance. Only creates security group rule if set. | `string` | `null` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region to use for running the machine | `string` | n/a | yes |
| <a name="input_cached_paths"></a> [cached\_paths](#input\_cached\_paths) | Paths which should be cached for all clients. | `list(string)` | <pre>[<br>  "/content/*",<br>  "/assets/*",<br>  "/public/*"<br>]</pre> | no |
| <a name="input_db_password"></a> [db\_password](#input\_db\_password) | The password for accessing the database. It is recommended to pass this as an environment variable, e.g. `TF_VAR_db_password`. | `string` | n/a | yes |
| <a name="input_deployment_name"></a> [deployment\_name](#input\_deployment\_name) | Name used for the deployment. | `string` | `"ghost"` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The fully qualified domain name used to access the website. Does not require a protocol prefix. | `string` | n/a | yes |
| <a name="input_ghost_extra_env_vars"></a> [ghost\_extra\_env\_vars](#input\_ghost\_extra\_env\_vars) | A map of k/v pairs to add as additional environment variables for the Ghost container. See https://ghost.org/docs/config/ | `map(string)` | `{}` | no |
| <a name="input_ghost_image"></a> [ghost\_image](#input\_ghost\_image) | The image of Ghost to run. | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type for the machine. If unset, a free-tier instance will be used. | `string` | `null` | no |
| <a name="input_private_cidrs"></a> [private\_cidrs](#input\_private\_cidrs) | List of CIDRs to use for private subnets. | `list(string)` | <pre>[<br>  "10.0.100.0/24",<br>  "10.0.102.0/24"<br>]</pre> | no |
| <a name="input_public_cidrs"></a> [public\_cidrs](#input\_public\_cidrs) | List of CIDRs to use for public subnets. | `list(string)` | <pre>[<br>  "10.0.0.0/24",<br>  "10.0.2.0/24"<br>]</pre> | no |
| <a name="input_ssh_keys"></a> [ssh\_keys](#input\_ssh\_keys) | SSH public keys for user 'core' | `list(string)` | n/a | yes |
| <a name="input_uncached_paths"></a> [uncached\_paths](#input\_uncached\_paths) | Paths which should not be cached. | `list(string)` | <pre>[<br>  "/ghost/*",<br>  "/members/*"<br>]</pre> | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | The CIDR block for the VPC. | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_acm_validation_records"></a> [dns\_acm\_validation\_records](#output\_dns\_acm\_validation\_records) | Record(s) required by ACM to validate TLS certificates. |
| <a name="output_dns_cloudfront_record"></a> [dns\_cloudfront\_record](#output\_dns\_cloudfront\_record) | Record required to point domain at the CDN. Use an ALIAS record if the `domain_name` is the apex, otherwise use a CNAME. |
| <a name="output_ec2_connection_details"></a> [ec2\_connection\_details](#output\_ec2\_connection\_details) | Use the following to connect to the EC2 instance as admin. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
