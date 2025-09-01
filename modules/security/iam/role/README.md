# IAM Role Module

This module creates an IAM role with the following features:

## Features

- ✅ **Flexible Trust Policy**: Configure which AWS services can assume the role
- ✅ **Managed Policies**: Attach AWS managed policies (like SSM policies)
- ✅ **Inline Policies**: Create custom inline policies for specific requirements
- ✅ **Instance Profile**: Automatically creates an instance profile for EC2 use
- ✅ **Tagging**: Consistent tagging across all resources

## Usage

### Basic EC2 Role with SSM Access

```hcl
module "ec2_ssm_role" {
  source = "../../../../modules/security/iam/role"
  
  role_name   = "ec2-ssm-role"
  description = "IAM role for EC2 instances with SSM access"
  
  # AWS managed policies for SSM
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]
  
  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

### Advanced Role with Custom Policies

```hcl
module "advanced_ec2_role" {
  source = "../../../../modules/security/iam/role"
  
  role_name   = "advanced-ec2-role"
  description = "Advanced IAM role for EC2 with custom permissions"
  
  # AWS managed policies
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
  
  # Custom inline policies
  inline_policies = [
    {
      name = "S3BucketAccess"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "s3:GetObject",
              "s3:PutObject"
            ]
            Resource = "arn:aws:s3:::my-bucket/*"
          }
        ]
      })
    }
  ]
  
  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

## Common AWS Managed Policies for EC2

| Policy | Purpose |
|--------|---------|
| `AmazonSSMManagedInstanceCore` | Basic SSM functionality (Session Manager, Systems Manager) |
| `CloudWatchAgentServerPolicy` | CloudWatch agent permissions |
| `AmazonS3ReadOnlyAccess` | Read-only access to S3 |
| `AmazonEC2RoleforAWSCodeDeploy` | CodeDeploy integration |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| role_name | Name of the IAM role | `string` | n/a | yes |
| description | Description of the IAM role | `string` | `"IAM role created by Terraform"` | no |
| trusted_services | List of AWS services that can assume this role | `list(string)` | `["ec2.amazonaws.com"]` | no |
| managed_policy_arns | List of AWS managed policy ARNs to attach | `list(string)` | `[]` | no |
| inline_policies | List of inline policies to attach | `list(object)` | `[]` | no |
| create_instance_profile | Whether to create an instance profile for EC2 | `bool` | `true` | no |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| role_arn | ARN of the IAM role |
| role_name | Name of the IAM role |
| role_id | ID of the IAM role |
| instance_profile_arn | ARN of the instance profile |
| instance_profile_name | Name of the instance profile |

## Examples

### EC2 with SSM Session Manager
```hcl
# Create IAM role for EC2 with SSM access
module "ec2_ssm_role" {
  source = "../../../../modules/security/iam/role"
  
  role_name   = "${var.project}-${var.environment}-ec2-ssm"
  description = "IAM role for EC2 instances with SSM access"
  
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
  
  tags = var.tags
}

# Use the role in EC2 instance
resource "aws_instance" "example" {
  # ... other configuration ...
  iam_instance_profile = module.ec2_ssm_role.instance_profile_name
}
```
