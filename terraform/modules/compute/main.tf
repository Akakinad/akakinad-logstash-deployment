# Security Group
resource "aws_security_group" "this" {
  name_prefix = "${var.instance_name}-sg"
  description = "Security group for ${var.instance_name}"
  vpc_id      = var.vpc_id

  # Dynamic ingress rules
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description     = ingress.key
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = ingress.value.cidr_blocks
      security_groups = ingress.value.source_security_group_id != "" ? [ingress.value.source_security_group_id] : []
    }
  }

  # Dynamic egress rules
  dynamic "egress" {
    for_each = var.egress_rules
    content {
      description = egress.key
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.instance_name}-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# EC2 Instance
resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.this.id]
  key_name               = var.key_name != "" ? var.key_name : null

  # Enable detailed monitoring
  monitoring = true

  # Root volume configuration
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true
  }

  # Instance metadata options (security best practice)
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
    http_put_response_hop_limit = 1
  }

  tags = merge(var.common_tags, {
    Name = var.instance_name
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Elastic IP (optional - only for bastion)
resource "aws_eip" "this" {
  count    = can(regex("bastion|jumpbox", lower(var.instance_name))) ? 1 : 0
  instance = aws_instance.this.id
  domain   = "vpc"

  tags = merge(var.common_tags, {
    Name = "${var.instance_name}-eip"
  })

  depends_on = [aws_instance.this]
}