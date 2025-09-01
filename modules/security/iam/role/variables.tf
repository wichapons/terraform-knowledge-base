variable "role_name" {
  type        = string
  description = "Name of the IAM role"
}

variable "description" {
  type        = string
  description = "Description of the IAM role"
  default     = "IAM role created by Terraform"
}

variable "trusted_services" {
  type        = list(string)
  description = "List of AWS services that can assume this role"
  default     = ["ec2.amazonaws.com"]
}

variable "managed_policy_arns" {
  type        = list(string)
  description = "List of AWS managed policy ARNs to attach to the role"
  default     = []
}

variable "inline_policies" {
  type = list(object({
    name   = string
    policy = string
  }))
  description = "List of inline policies to attach to the role"
  default     = []
}

variable "create_instance_profile" {
  type        = bool
  description = "Whether to create an instance profile for EC2"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the IAM role and instance profile"
  default     = {}
}
