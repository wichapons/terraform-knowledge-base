locals {
  common_vars  = read_terragrunt_config(find_in_parent_folders("common_vars.hcl"))

  aws_configuration = local.common_vars.inputs.aws_configuration
  common_tags       = local.common_vars.inputs.tags

  project     = "api-gateway-lambda-auth"
  environment = local.common_tags.environment
  region      = local.aws_configuration.region

  module_tags = merge(local.common_tags, { "module" = "security-group" })
}

terraform {
  source = "../../../../../modules/compute/security_group"
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
  name        = "${local.project}-${local.environment}-sg"
  description = "Security group for sandbox-top services"
  vpc_id      = dependency.vpc.outputs.vpc_id
  ingress_rules = []
  tags = local.module_tags
}
