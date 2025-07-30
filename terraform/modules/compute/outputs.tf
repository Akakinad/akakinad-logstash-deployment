output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_instance.this.arn
}

output "instance_private_ip" {
  description = "Private IP address of the instance"
  value       = aws_instance.this.private_ip
}

output "instance_public_ip" {
  description = "Public IP address of the instance (if in public subnet)"
  value       = aws_instance.this.public_ip
}

output "elastic_ip" {
  description = "Elastic IP address (if created)"
  value       = length(aws_eip.this) > 0 ? aws_eip.this[0].public_ip : null
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.this.id
}

output "security_group_arn" {
  description = "ARN of the security group"
  value       = aws_security_group.this.arn
}

output "instance_state" {
  description = "State of the instance"
  value       = aws_instance.this.instance_state
}

output "availability_zone" {
  description = "Availability zone of the instance"
  value       = aws_instance.this.availability_zone
}

output "key_name" {
  description = "Key pair name used by the instance"
  value       = aws_instance.this.key_name
}