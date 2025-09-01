# EC2 Module

This module creates a single EC2 instance with common options for reuse across projects.

Inputs (high-level):
- project, environment: naming tags
- ami, instance_type: instance selection
- subnet_id, security_group_ids: networking
- key_name, user_data: access and bootstrapping
- root_volume_size/type: storage

Outputs:
- instance_id, public_ip, private_ip

Example usage:

```hcl
module "web" {
  source = "../../modules/compute/ec2"

  project      = var.project
  environment  = var.environment
  ami          = var.ami
  instance_type = "t3.micro"
  subnet_id    = module.vpc.public_subnet_ids[0]
  security_group_ids = [aws_security_group.web.id]
}
```
