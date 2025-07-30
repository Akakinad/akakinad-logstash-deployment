# Networking Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.networking.vpc_cidr_block
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = module.networking.public_subnet_id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = module.networking.private_subnet_id
}

# Bastion Host Outputs
output "bastion_instance_id" {
  description = "ID of the bastion host instance"
  value       = module.bastion.instance_id
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = module.bastion.elastic_ip
}

output "bastion_private_ip" {
  description = "Private IP of the bastion host"
  value       = module.bastion.instance_private_ip
}

output "bastion_security_group_id" {
  description = "Security group ID of the bastion host"
  value       = module.bastion.security_group_id
}

# Logstash Server Outputs
output "logstash_instance_id" {
  description = "ID of the Logstash server instance"
  value       = module.logstash.instance_id
}

output "logstash_private_ip" {
  description = "Private IP of the Logstash server"
  value       = module.logstash.instance_private_ip
}

output "logstash_security_group_id" {
  description = "Security group ID of the Logstash server"
  value       = module.logstash.security_group_id
}

# Connection Information
output "ssh_to_bastion" {
  description = "SSH command to connect to bastion host"
  value       = "ssh -i ~/.ssh/your-key.pem ec2-user@${module.bastion.elastic_ip}"
}

output "ssh_to_logstash_via_bastion" {
  description = "SSH command to connect to Logstash via bastion"
  value       = "ssh -i ~/.ssh/your-key.pem -J ec2-user@${module.bastion.elastic_ip} ec2-user@${module.logstash.instance_private_ip}"
}

# Ansible Inventory Information
output "ansible_inventory_info" {
  description = "Information for Ansible inventory"
  value = {
    bastion_public_ip    = module.bastion.elastic_ip
    bastion_instance_id  = module.bastion.instance_id
    logstash_private_ip  = module.logstash.instance_private_ip
    logstash_instance_id = module.logstash.instance_id
  }
}