resource "aws_security_group" "this" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id
  tags = merge(var.tags, {
    Name = var.name
  })
}

# Manage ingress rules as separate resources for better tracking
resource "aws_security_group_rule" "ingress" {
  count = length(var.ingress_rules)

  type              = var.ingress_rules[count.index].type
  protocol          = var.ingress_rules[count.index].protocol
  from_port         = var.ingress_rules[count.index].from_port
  to_port           = var.ingress_rules[count.index].to_port
  security_group_id = aws_security_group.this.id

  # Handle different source types
  cidr_blocks              = length(coalesce(var.ingress_rules[count.index].cidr_blocks, [])) > 0 ? var.ingress_rules[count.index].cidr_blocks : null
  ipv6_cidr_blocks        = length(coalesce(var.ingress_rules[count.index].ipv6_cidr_blocks, [])) > 0 ? var.ingress_rules[count.index].ipv6_cidr_blocks : null
  source_security_group_id = var.ingress_rules[count.index].source_security_group_id != "" ? var.ingress_rules[count.index].source_security_group_id : null
  prefix_list_ids         = length(coalesce(var.ingress_rules[count.index].prefix_list_ids, [])) > 0 ? var.ingress_rules[count.index].prefix_list_ids : null

  description = var.ingress_rules[count.index].description
}

# Manage egress rules as separate resources for better tracking
resource "aws_security_group_rule" "egress" {
  count = length(var.egress_rules)

  type              = var.egress_rules[count.index].type
  protocol          = var.egress_rules[count.index].protocol
  from_port         = var.egress_rules[count.index].from_port
  to_port           = var.egress_rules[count.index].to_port
  security_group_id = aws_security_group.this.id

  # Handle different source types
  cidr_blocks              = length(coalesce(var.egress_rules[count.index].cidr_blocks, [])) > 0 ? var.egress_rules[count.index].cidr_blocks : null
  ipv6_cidr_blocks        = length(coalesce(var.egress_rules[count.index].ipv6_cidr_blocks, [])) > 0 ? var.egress_rules[count.index].ipv6_cidr_blocks : null
  source_security_group_id = var.egress_rules[count.index].source_security_group_id != "" ? var.egress_rules[count.index].source_security_group_id : null
  prefix_list_ids         = length(coalesce(var.egress_rules[count.index].prefix_list_ids, [])) > 0 ? var.egress_rules[count.index].prefix_list_ids : null

  description = var.egress_rules[count.index].description
}
