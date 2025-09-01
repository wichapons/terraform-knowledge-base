output "instance_id" {
  value = aws_instance.this.id
}

output "public_ip" {
  value = aws_instance.this.public_ip
  description = "Public IP assigned to the instance (if any)."
}

output "private_ip" {
  value = aws_instance.this.private_ip
}
