locals {
  common_vars  = read_terragrunt_config(find_in_parent_folders("common_vars.hcl"))

  aws_configuration = local.common_vars.inputs.aws_configuration
  common_tags       = local.common_vars.inputs.tags

  project     = local.common_vars.inputs.project
  environment = local.common_tags.environment
  region      = local.aws_configuration.region

  module_tags = merge(local.common_tags, { "module" = "nlb" })
}

terraform {
  source = "../../../../../modules/load-balancer/nlb"
}

dependency "vpc" {
  config_path = "../vpc"
  
  mock_outputs = {
    vpc_id              = "vpc-mock-id"
    public_subnet_ids   = ["subnet-mock-1", "subnet-mock-2"]
    private_subnet_ids  = ["subnet-mock-3", "subnet-mock-4"]
  }
}

dependency "security_group" {
  config_path = "../security-group"
  
  mock_outputs = {
    security_group_id = "sg-mock-id"
  }
}

dependency "ec2" {
  config_path = "../compute/ec2"
  
  mock_outputs = {
    instance_id = "i-mock-instance"
  }
}

dependencies {
  paths = ["../vpc", "../security-group", "../compute/ec2"]
}

inputs = {
  name            = "${local.project}-${local.environment}-nlb"
  internal        = false  
  subnet_ids      = dependency.vpc.outputs.public_subnet_ids
  vpc_id          = dependency.vpc.outputs.vpc_id
  security_groups = [dependency.security_group.outputs.security_group_id]

  enable_deletion_protection = false

  target_groups = [
    {
      name        = "${local.project}-${local.environment}"
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
      target_id          = dependency.ec2.outputs.instance_id
      port               = 80
    }
  ]

  tags = local.module_tags
}