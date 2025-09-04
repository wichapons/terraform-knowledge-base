inputs = {
  aws_configuration = {
    "profile" = "terraform-poc-top"
    "region" = "ap-southeast-1"   
    "skip_region_validation"  = true
  }
  
  project = "api-gateway-lambda-auth"
  
  # Account-specific tags
  tags = {
    "environment"    = "dev"
    "created-by"     = "Top"
    "created-at"     = formatdate("DD-MMM-YY", timestamp())
    "managed-by"     = "terraform"
    "cross-account"  = "false"
  }

  
}



