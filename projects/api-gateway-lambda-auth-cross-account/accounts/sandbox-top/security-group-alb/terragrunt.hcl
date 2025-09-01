locals {
  common_vars  = read_terragrunt_config(find_in_parent_folders("common_vars.hcl"))

  aws_configuration = local.common_vars.inputs.aws_configuration
  common_tags       = local.common_vars.inputs.tags

  project     = local.common_vars.inputs.project
  environment = local.common_tags.environment
  region      = local.aws_configuration.region

  module_tags = merge(local.common_tags, { "module" = "security-group-alb" })
}

terraform {
  source = "../../../../../modules/security/security-group"
}

dependency "vpc" {
  config_path = "../vpc"
  
  mock_outputs = {
    vpc_id = "vpc-mock-id"
  }
  
}


dependencies {
  paths = ["../vpc"]
}

inputs = {
  name        = "${local.project}-${local.environment}-sg-alb"
  description = "Security group for Application Load Balancer (HTTP)"
  vpc_id      = dependency.vpc.outputs.vpc_id

  # Ingress rules - allow HTTP from anywhere
  ingress_rules = [
    {
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTP (80) from anywhere to ALB"
    }
  ]
  
  # Egress rules - allow all outbound
  egress_rules = [
    {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]
  
  tags = local.module_tags
}
