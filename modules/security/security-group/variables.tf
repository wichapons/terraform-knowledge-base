variable "name" {
  type = string
}

variable "description" {
  type    = string
  default = "Managed security group"
}

variable "vpc_id" {
  type = string
}

variable "ingress_rules" {
  type = list(object({
    type                     = string
    from_port               = number
    to_port                 = number
    protocol                = string
    cidr_blocks             = optional(list(string))
    ipv6_cidr_blocks        = optional(list(string))
    source_security_group_id = optional(string, "")
    prefix_list_ids         = optional(list(string))
    description             = optional(string)
  }))
  default = []
  description = "List of ingress rules for the security group"
}

variable "egress_rules" {
  type = list(object({
    type                     = string
    from_port               = number
    to_port                 = number
    protocol                = string
    cidr_blocks             = optional(list(string))
    ipv6_cidr_blocks        = optional(list(string))
    source_security_group_id = optional(string, "")
    prefix_list_ids         = optional(list(string))
    description             = optional(string)
  }))
  default = [{
    type        = "egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }]
  description = "List of egress rules for the security group"
}

variable "tags" {
  type    = map(string)
  default = {}
}
