variable "project" {
    type = string
}

variable "environment" {
    type = string
}

variable "vpc_cidr" {
    type = string
}

variable "public_subnet_cidrs" {
    type = list(string)
}

variable "private_subnet_cidrs" {
    type = list(string)
    default = []
    description = "CIDR blocks for private subnets. If empty, no private subnets will be created."
}

variable "create_nat_gateway" {
    type        = bool
    default     = true
    description = "Whether to create a NAT Gateway for private subnets. If false, private subnets will be created without internet access."
}

variable "single_nat_gateway" {
    type        = bool
    default     = true
    description = "Whether to create a single NAT Gateway (true) or one per AZ for high availability (false)."
}

variable "azs" {
    type = list(string)
}

variable "tags" {
    type    = map(string)
    default = {}
}
