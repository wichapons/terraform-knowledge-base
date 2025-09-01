# IAM Role for EC2 instances
resource "aws_iam_role" "this" {
  name               = var.role_name
  description        = var.description
  assume_role_policy = data.aws_iam_policy_document.trust_policy.json

  tags = merge(var.tags, {
    Name = var.role_name
  })
}

# Trust policy allowing EC2 to assume this role
data "aws_iam_policy_document" "trust_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = var.trusted_services
    }
    actions = ["sts:AssumeRole"]
  }
}

# Attach AWS managed policies
resource "aws_iam_role_policy_attachment" "managed_policies" {
  count = length(var.managed_policy_arns)
  
  role       = aws_iam_role.this.name
  policy_arn = var.managed_policy_arns[count.index]
}

# Create and attach custom inline policies
resource "aws_iam_role_policy" "inline_policies" {
  count = length(var.inline_policies)
  
  name   = var.inline_policies[count.index].name
  role   = aws_iam_role.this.id
  policy = var.inline_policies[count.index].policy
}

# Instance profile for EC2
resource "aws_iam_instance_profile" "this" {
  count = var.create_instance_profile ? 1 : 0
  
  name = "${var.role_name}-instance-profile"
  role = aws_iam_role.this.name

  tags = merge(var.tags, {
    Name = "${var.role_name}-instance-profile"
  })
}
