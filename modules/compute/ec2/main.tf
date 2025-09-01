resource "aws_instance" "this" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  associate_public_ip_address = var.associate_public_ip

  vpc_security_group_ids = var.security_group_ids
  iam_instance_profile   = var.iam_instance_profile != "" ? var.iam_instance_profile : null

  user_data              = var.user_data

  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}"
  })

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
    delete_on_termination = true
  }
}
