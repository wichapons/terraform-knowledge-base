inputs = {
  aws_configuration = {
    "profile" = "terraform-poc-top"
    "region" = "ap-southeast-1"
    "skip_region_validation"  = true
  }

  s3_bucket_name = "terraform-state-kb-trueidc-th" 
  dynamodb_table_name = "terraform-dynamodb-lockid-kb-trueidc-th" 
   
    tags = {
    "environment"    = "dev"
    "created-by"     = "Top"
    "created-at"     = formatdate("DD-MMM-YY", timestamp())
    "managed-by"     = "terraform"
  }
}





 