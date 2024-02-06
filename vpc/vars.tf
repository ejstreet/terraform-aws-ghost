variable "name" {
  type = string
}
variable "vpc_cidr" {
  type = string
}

variable "public_cidrs" {
  type = list(string)
}

variable "private_cidrs" {
  type = list(string)
}

variable "public_ingress_rules" {
  type    = map(any)
  default = {}
}
variable "public_egress_rules" {
  type    = map(any)
  default = {}
}

variable "private_ingress_rules" {
  type    = map(any)
  default = {}
}

variable "private_egress_rules" {
  type    = map(any)
  default = {}
}
