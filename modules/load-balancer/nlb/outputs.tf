output "nlb_id" {
  description = "The ID and ARN of the load balancer"
  value       = aws_lb.this.id
}

output "nlb_arn" {
  description = "The ARN of the load balancer"
  value       = aws_lb.this.arn
}

output "nlb_arn_suffix" {
  description = "The ARN suffix for use with CloudWatch Metrics"
  value       = aws_lb.this.arn_suffix
}

output "nlb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.this.dns_name
}

output "nlb_hosted_zone_id" {
  description = "The canonical hosted zone ID of the load balancer"
  value       = aws_lb.this.zone_id
}

output "target_group_arns" {
  description = "ARNs of the target groups"
  value       = aws_lb_target_group.this[*].arn
}

output "target_group_arn_suffixes" {
  description = "ARN suffixes of the target groups for use with CloudWatch Metrics"
  value       = aws_lb_target_group.this[*].arn_suffix
}

output "target_group_names" {
  description = "Names of the target groups"
  value       = aws_lb_target_group.this[*].name
}

output "listener_arns" {
  description = "The ARNs of the load balancer listeners"
  value       = aws_lb_listener.this[*].arn
}
