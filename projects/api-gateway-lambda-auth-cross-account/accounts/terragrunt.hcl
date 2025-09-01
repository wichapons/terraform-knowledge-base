# /accounts/terragrunt.hcl

locals {
  # Global, immutable for backend config
  global_common = read_terragrunt_config(find_in_parent_folders("/projects/api-gateway-lambda-auth-cross-account/accounts/common_vars.hcl"))

}

# BACKEND CONFIGURATION (uses ONLY global_common)
remote_state {
  backend = "s3"
  config = {
    profile                = local.global_common.inputs.aws_configuration.profile
    encrypt                = true
    bucket                 = local.global_common.inputs.s3_bucket_name
    key                    = "${path_relative_to_include()}/terraform.tfstate"
    region                 = local.global_common.inputs.aws_configuration.region
    skip_region_validation = local.global_common.inputs.aws_configuration.skip_region_validation
    dynamodb_table         = local.global_common.inputs.dynamodb_table_name

    s3_bucket_tags = merge(local.global_common.inputs.tags, { Name = "Terraform state storage" })
    dynamodb_table_tags = merge(local.global_common.inputs.tags, { Name = "Terraform lock table" })
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
