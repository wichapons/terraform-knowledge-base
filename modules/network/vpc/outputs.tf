output "vpc_id" {
    value = aws_vpc.this.id
}

output "public_subnet_ids" {
    value = [for subnet in aws_subnet.public : subnet.id]
}

output "public_subnet_cidrs" {
    value = [for subnet in aws_subnet.public : subnet.cidr_block]
}

output "private_subnet_ids" {
    value = [for subnet in aws_subnet.private : subnet.id]
}

output "private_subnet_cidrs" {
    value = [for subnet in aws_subnet.private : subnet.cidr_block]
}

output "vpc_cidr" {
    value = aws_vpc.this.cidr_block
}

output "private_route_table_ids" {
    description = "List of IDs of the private route tables"
    value       = aws_route_table.private[*].id
}

output "public_route_table_id" {
    description = "ID of the public route table"
    value       = aws_route_table.public.id
}
