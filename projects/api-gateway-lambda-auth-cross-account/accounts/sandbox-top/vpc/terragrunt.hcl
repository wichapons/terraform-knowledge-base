locals {
  common_vars  = read_terragrunt_config(find_in_parent_folders("common_vars.hcl"))
  
  # Extract values from common_vars
  aws_configuration = local.common_vars.inputs.aws_configuration
  common_tags       = local.common_vars.inputs.tags
  
  # Define local variables
  project           = local.common_vars.inputs.project
  environment       = local.common_tags.environment
  region           = local.aws_configuration.region
  
  # Define availability zones for the region
  azs = ["${local.region}a", "${local.region}b"]
  
  # Merge common tags with module-specific tags
  module_tags = merge(local.common_tags)
}

terraform {
  source = "../../../../../modules/network/vpc"
}

# Pass inputs to the Terraform module
inputs = {
  project              = local.project
  environment          = local.environment
  
  # Smaller RFC-1918 range for non-prod
  vpc_cidr             = "10.10.0.0/16"
  
  # Two /24 public subnets
  public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
  
  # Two /24 private subnets
  private_subnet_cidrs = ["10.10.10.0/24", "10.10.11.0/24"]
  
  # Enable NAT Gateway for development environment
  create_nat_gateway   = false
  
  # For dev, use single NAT Gateway to save costs
  single_nat_gateway   = false
  
  azs                  = local.azs
  tags                 = local.module_tags
}


