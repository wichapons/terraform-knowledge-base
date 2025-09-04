variable "name" {
  description = "The name of the Network Load Balancer"
  type        = string
}

variable "internal" {
  description = "If true, the NLB will be internal"
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "A list of subnet IDs to attach to the NLB"
  type        = list(string)
}

variable "security_groups" {
  description = "A list of security group IDs to assign to the NLB"
  type        = list(string)
  default     = null
}

variable "vpc_id" {
  description = "VPC ID where the NLB will be created"
  type        = string
}

variable "enable_deletion_protection" {
  description = "If true, deletion of the load balancer will be disabled via the AWS API"
  type        = bool
  default     = false
}

variable "access_logs" {
  description = "An access logs block"
  type = object({
    bucket  = string
    prefix  = optional(string)
    enabled = optional(bool, true)
  })
  default = null
}

variable "target_groups" {
  description = "A list of target group configurations"
  type = list(object({
    name        = string
    port        = number
    protocol    = string
    target_type = optional(string, "instance")
    health_check = optional(object({
      enabled             = optional(bool, true)
      healthy_threshold   = optional(number, 3)
      interval            = optional(number, 30)
      matcher             = optional(string)
      path                = optional(string)
      port                = optional(string, "traffic-port")
      protocol            = optional(string, "TCP")
      timeout             = optional(number, 10)
      unhealthy_threshold = optional(number, 3)
    }))
    stickiness = optional(object({
      type            = string
      cookie_duration = optional(number)
      enabled         = optional(bool, false)
    }))
  }))
  default = []
}

variable "target_attachments" {
  description = "A list of target attachments"
  type = list(object({
    target_group_index = number
    target_id          = string
    port               = optional(number)
  }))
  default = []
}

variable "listeners" {
  description = "A list of listener configurations"
  type = list(object({
    port     = number
    protocol = string
    default_action = object({
      type               = string
      target_group_arn   = optional(string)
      target_group_index = optional(number)
      forward = optional(object({
        target_groups = list(object({
          arn                = optional(string)
          target_group_index = optional(number)
          weight             = optional(number, 100)
        }))
        stickiness = optional(object({
          enabled  = optional(bool, false)
          duration = optional(number, 1)
        }))
      }))
    })
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
