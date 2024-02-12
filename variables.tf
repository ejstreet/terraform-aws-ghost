variable "aws_region" {
  type        = string
  description = "AWS Region to use for running the machine"
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "public_cidrs" {
  description = "List of CIDRs to use for public subnets."
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.2.0/24"]
}

variable "private_cidrs" {
  description = "List of CIDRs to use for private subnets."
  type        = list(string)
  default     = ["10.0.100.0/24", "10.0.102.0/24"]
}

variable "deployment_name" {
  type        = string
  description = "Name used for the deployment."
  default     = "ghost"
}

variable "domain_name" {
  type        = string
  description = "The fully qualified domain name used to access the website. Does not require a protocol prefix."
}

variable "admin_ip" {
  type        = string
  description = "IP address with subnet mask (ideally `/32`) of admin to allow direct access to the instance. Only creates security group rule if set."
  default     = null
}

variable "ghost_image" {
  type        = string
  description = "The image of Ghost to run."
}

variable "ssh_keys" {
  type        = list(string)
  description = "SSH public keys for user 'core'"
}

variable "db_password" {
  type        = string
  description = "The password for accessing the database. It is recommended to pass this as an environment variable, e.g. `TF_VAR_db_password`."
  sensitive   = true
}

variable "instance_type" {
  type        = string
  default     = null
  description = "Instance type for the machine. If unset, a free-tier instance will be used."
}

variable "cached_paths" {
  type        = list(string)
  default     = ["/content/*", "/assets/*", "/public/*"]
  description = "Paths which should be cached for all clients."
}

variable "uncached_paths" {
  type        = list(string)
  default     = ["/ghost/*", "/members/*"]
  description = "Paths which should not be cached."
}

variable "ghost_extra_env_vars" {
  description = "A map of k/v pairs to add as additional environment variables for the Ghost container. See https://ghost.org/docs/config/"
  type        = map(string)
  default     = {}
}
