# Security Group Module

Reusable security group module supporting structured ingress/egress rules.

Inputs:
- name, description, vpc_id
- ingress_rules: list of objects {from_port,to_port,protocol,cidr_blocks,..}
- egress_rules: list (defaults to allow all outbound)
- tags

Outputs:
- security_group_id

Example usage:

```hcl
module "web_sg" {
  source = "../../modules/compute/security_group"
  name   = "web-sg"
  vpc_id = module.vpc.vpc_id
  ingress_rules = [
    { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["10.0.0.0/16"] }
  ]
}
```
