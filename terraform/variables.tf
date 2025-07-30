variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "akakinad-logstash"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

variable "my_ip" {
  description = "Your public IP address for SSH access (format: x.x.x.x/32)"
  type        = string
}

variable "bastion_instance_type" {
  description = "Instance type for bastion host"
  type        = string
  default     = "t3.micro"
}

variable "logstash_instance_type" {
  description = "Instance type for Logstash server"
  type        = string
  default     = "t3.medium"
}

variable "key_pair_name" {
  description = "AWS Key Pair name for SSH access"
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "akakinad-logstash-deployment"
    ManagedBy   = "Terraform"
    Owner       = "akakinad"
    Environment = "dev"
  }
}

variable "aws_profile" {
  description = "AWS profile to use for authentication"
  type        = string
  default     = ""
}