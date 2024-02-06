variable "instance_name" {
  type        = string
  description = "Name used for the instance"
  default     = "Ghost"
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

variable "aws_region" {
  type        = string
  description = "AWS Region to use for running the machine"
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

variable "uncached_paths" {
  type    = list(string)
  default = ["/ghost/*", "/members/*"]
}

variable "vpc" {
  type = object({
    cidr                 = string
    public_cidrs         = list(string)
    public_ingress_rules = map(any)
    public_egress_rules  = map(any)
    private_cidrs        = list(string)
  })
  default = {
    cidr         = "10.0.0.0/16"
    public_cidrs = ["10.0.0.0/24", "10.0.2.0/24"]
    public_ingress_rules = {
      "HTTP" = {
        from_port   = 80
        ip_protocol = "TCP"
        cidr_ipv4   = "0.0.0.0/0"
      }
      "HTTPS" = {
        from_port   = 443
        ip_protocol = "TCP"
        cidr_ipv4   = "0.0.0.0/0"
      }
    }
    public_egress_rules = {
      "Allow All" = {
        cidr_ipv4 = "0.0.0.0/0"
      }
    }
    private_cidrs = ["10.0.100.0/24", "10.0.102.0/24"]
  }
}
