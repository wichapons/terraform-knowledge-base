# Network Load Balancer (NLB) Module

This Terraform module creates an AWS Network Load Balancer (NLB) with associated target groups, listeners, and target attachments.

## Features

- Creates a Network Load Balancer (internal or internet-facing)
- Support for private IP addresses on internal NLBs via subnet mapping
- Supports multiple target groups with flexible configuration
- Configurable health checks for target groups
- Support for multiple listeners
- Target group attachments for EC2 instances
- Access logs configuration
- Comprehensive tagging support

## Usage

```hcl
module "nlb" {
  source = "./modules/load-balancer/nlb"

  name            = "my-nlb"
  internal        = false
  subnet_ids      = ["subnet-12345", "subnet-67890"]
  vpc_id          = "vpc-12345"
  security_groups = ["sg-12345"]

  target_groups = [
    {
      name        = "web-servers"
      port        = 80
      protocol    = "TCP"
      target_type = "instance"
      health_check = {
        enabled             = true
        healthy_threshold   = 2
        interval            = 30
        port                = "traffic-port"
        protocol            = "TCP"
        timeout             = 10
        unhealthy_threshold = 2
      }
    }
  ]

  listeners = [
    {
      port     = 80
      protocol = "TCP"
      default_action = {
        type               = "forward"
        target_group_index = 0
      }
    }
  ]

  target_attachments = [
    {
      target_group_index = 0
      target_id          = "i-1234567890abcdef0"
      port               = 80
    }
  ]

  tags = {
    Environment = "dev"
    Project     = "my-project"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the Network Load Balancer | `string` | n/a | yes |
| internal | If true, the NLB will be internal | `bool` | `false` | no |
| subnet_ids | A list of subnet IDs to attach to the NLB (used when subnet_mapping is not specified) | `list(string)` | `null` | no |
| subnet_mapping | A list of subnet mapping blocks for internal NLBs with private IP addresses | `list(object)` | `null` | no |
| security_groups | A list of security group IDs to assign to the NLB | `list(string)` | `null` | no |
| vpc_id | VPC ID where the NLB will be created | `string` | n/a | yes |
| enable_deletion_protection | If true, deletion of the load balancer will be disabled via the AWS API | `bool` | `false` | no |
| access_logs | An access logs block | `object` | `null` | no |
| target_groups | A list of target group configurations | `list(object)` | `[]` | no |
| target_attachments | A list of target attachments | `list(object)` | `[]` | no |
| listeners | A list of listener configurations | `list(object)` | `[]` | no |
| tags | A map of tags to assign to the resource | `map(string)` | `{}` | no |

**Note:** You must specify either `subnet_ids` or `subnet_mapping`, but not both.

## Outputs

| Name | Description |
|------|-------------|
| nlb_id | The ID and ARN of the load balancer |
| nlb_arn | The ARN of the load balancer |
| nlb_arn_suffix | The ARN suffix for use with CloudWatch Metrics |
| nlb_dns_name | The DNS name of the load balancer |
| nlb_hosted_zone_id | The canonical hosted zone ID of the load balancer |
| target_group_arns | ARNs of the target groups |
| target_group_arn_suffixes | ARN suffixes of the target groups for use with CloudWatch Metrics |
| target_group_names | Names of the target groups |
| listener_arns | The ARNs of the load balancer listeners |

## Examples

### Basic NLB with single target group

```hcl
module "basic_nlb" {
  source = "./modules/load-balancer/nlb"

  name       = "basic-nlb"
  internal   = false
  subnet_ids = var.public_subnet_ids
  vpc_id     = var.vpc_id

  target_groups = [
    {
      name        = "web-targets"
      port        = 80
      protocol    = "TCP"
      target_type = "instance"
    }
  ]

  listeners = [
    {
      port     = 80
      protocol = "TCP"
      default_action = {
        type               = "forward"
        target_group_index = 0
      }
    }
  ]

  tags = var.tags
}
```

### Internal NLB with private IP addresses

```hcl
module "internal_nlb_with_private_ips" {
  source = "./modules/load-balancer/nlb"

  name     = "internal-nlb-private-ips"
  internal = true
  vpc_id   = var.vpc_id

  subnet_mapping = [
    {
      subnet_id            = var.private_subnet_ids[0]
      private_ipv4_address = "10.0.1.100"
    },
    {
      subnet_id            = var.private_subnet_ids[1]
      private_ipv4_address = "10.0.2.100"
    }
  ]

  target_groups = [
    {
      name        = "app-servers"
      port        = 80
      protocol    = "TCP"
      target_type = "instance"
      health_check = {
        enabled             = true
        healthy_threshold   = 2
        interval            = 30
        port                = "traffic-port"
        protocol            = "TCP"
        timeout             = 10
        unhealthy_threshold = 2
      }
    }
  ]

  listeners = [
    {
      port     = 80
      protocol = "TCP"
      default_action = {
        type               = "forward"
        target_group_index = 0
      }
    }
  ]

  tags = var.tags
}
```

### Internal NLB with multiple target groups

```hcl
module "internal_nlb" {
  source = "./modules/load-balancer/nlb"

  name       = "internal-nlb"
  internal   = true
  subnet_ids = var.private_subnet_ids
  vpc_id     = var.vpc_id

  target_groups = [
    {
      name        = "app-servers"
      port        = 8080
      protocol    = "TCP"
      target_type = "instance"
      health_check = {
        enabled             = true
        healthy_threshold   = 3
        interval            = 30
        port                = "8080"
        protocol            = "TCP"
        timeout             = 10
        unhealthy_threshold = 3
      }
    },
    {
      name        = "api-servers"
      port        = 3000
      protocol    = "TCP"
      target_type = "instance"
    }
  ]

  listeners = [
    {
      port     = 8080
      protocol = "TCP"
      default_action = {
        type               = "forward"
        target_group_index = 0
      }
    },
    {
      port     = 3000
      protocol = "TCP"
      default_action = {
        type               = "forward"
        target_group_index = 1
      }
    }
  ]

  tags = var.tags
}
```

## Notes

- Network Load Balancers operate at Layer 4 (TCP/UDP) and provide ultra-high performance
- Target groups can be of type `instance`, `ip`, or `lambda`
- Health checks for NLB are limited compared to ALB (TCP-based only unless using HTTP/HTTPS)
- NLB preserves the client IP address
- Cross-zone load balancing is disabled by default for NLB (unlike ALB)
