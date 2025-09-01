locals {
  common_vars  = read_terragrunt_config(find_in_parent_folders("common_vars.hcl"))

  aws_configuration = local.common_vars.inputs.aws_configuration
  common_tags       = local.common_vars.inputs.tags
  project     = local.common_vars.inputs.project
  environment = local.common_tags.environment
  region      = local.aws_configuration.region

  module_tags = merge(local.common_tags, { "module" = "iam-role" })
}

terraform {
  source = "../../../../../modules/security/iam/role"
}

inputs = {
  role_name   = "${local.project}-${local.environment}-ec2-ssm-role"
  description = "IAM role for EC2 instances with SSM access in ${local.environment}"
  
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]
  
  # Create instance profile for EC2
  create_instance_profile = true
  
  tags = local.module_tags
}
