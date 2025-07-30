variable "instance_name" {
  description = "Name for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID for the instance"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the instance will be created"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for security group"
  type        = string
}

variable "key_name" {
  description = "AWS Key Pair name for SSH access"
  type        = string
  default     = ""
}

variable "ingress_rules" {
  description = "Map of ingress rules for the security group"
  type = map(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = optional(list(string), [])
    source_security_group_id = optional(string, "")
  }))
  default = {}
}

variable "egress_rules" {
  description = "Map of egress rules for the security group"
  type = map(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = optional(list(string), ["0.0.0.0/0"])
  }))
  default = {
    "all_outbound" = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project   = "logstash-deployment"
    ManagedBy = "Terraform"
  }
}