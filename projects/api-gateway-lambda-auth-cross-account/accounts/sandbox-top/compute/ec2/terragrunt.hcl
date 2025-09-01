locals {
  common_vars  = read_terragrunt_config(find_in_parent_folders("common_vars.hcl"))

  aws_configuration = local.common_vars.inputs.aws_configuration
  common_tags       = local.common_vars.inputs.tags

  project     = local.common_vars.inputs.project
  environment = local.common_tags.environment
  region      = local.aws_configuration.region

  module_tags = merge(local.common_tags, { "module" = "ec2" })
}

terraform {
  source = "../../../../../../modules/compute/ec2"
}

dependency "vpc" {
  config_path = "../../vpc"
  
  mock_outputs = {
    vpc_id = "vpc-mock-id"
    private_subnet_ids = ["subnet-mock-id"]
  }
  
}

dependency "sg" {
  config_path = "../../security-group"
  
  mock_outputs = {
    security_group_id = "sg-mock-id"
  }
  
}

dependency "iam_role" {
  config_path = "../../iam-role"
  
  mock_outputs = {
    instance_profile_name = "mock-instance-profile"
  }
}

dependencies {
  paths = ["../../vpc", "../../security-group", "../../iam-role"]
}


# Note: you must provide a valid AMI id for your region. Replace the empty string or
# inject an `ami` via a parent `common_vars.hcl` if you want to centralize it.
inputs = {
  project       = local.project
  environment   = local.environment

  ami           = "ami-0f458a6b68ce01b7a" 

  instance_type = "t3.micro"

  # Use the first private subnet from the VPC dependency
  subnet_id     = dependency.vpc.outputs.private_subnet_ids[0]

  # No public IP on private subnet
  associate_public_ip = false

  # Security group created in sibling stack
  security_group_ids = [dependency.sg.outputs.security_group_id]

  # IAM instance profile for SSM access
  iam_instance_profile = dependency.iam_role.outputs.instance_profile_name

  key_name = ""

  user_data = ""

  tags = local.module_tags
}
