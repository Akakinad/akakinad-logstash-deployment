# Terraform configuration
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
  profile = var.aws_profile != "" ? var.aws_profile : null
  
  default_tags {
    tags = var.common_tags
  }
}

# Get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Networking Module - Creates VPC, subnets, gateways
module "networking" {
  source = "./modules/networking"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr          = var.vpc_cidr
  availability_zones = var.availability_zones
  common_tags       = var.common_tags
}

# Bastion Host - Secure gateway in public subnet
module "bastion" {
  source = "./modules/compute"

  instance_name = "${var.project_name}-${var.environment}-bastion"
  instance_type = var.bastion_instance_type
  ami_id        = data.aws_ami.amazon_linux.id
  subnet_id     = module.networking.public_subnet_id
  vpc_id        = module.networking.vpc_id
  key_name      = var.key_pair_name
  common_tags   = var.common_tags

  # Security rules for bastion host
  ingress_rules = {
    "ssh_from_my_ip" = {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.my_ip]
    }
    "ssh_from_ec2_instance_connect" = {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["18.237.140.160/29"] # EC2 Instance Connect for us-west-2
    }
  }

  egress_rules = {
    "all_outbound" = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  depends_on = [module.networking]
}

# Logstash Server - Log processor in private subnet
module "logstash" {
  source = "./modules/compute"

  instance_name = "${var.project_name}-${var.environment}-logstash"
  instance_type = var.logstash_instance_type
  ami_id        = data.aws_ami.amazon_linux.id
  subnet_id     = module.networking.private_subnet_id
  vpc_id        = module.networking.vpc_id
  key_name      = var.key_pair_name
  common_tags   = var.common_tags

  # Security rules for logstash server
  ingress_rules = {
    "ssh_from_bastion" = {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      source_security_group_id = module.bastion.security_group_id
    }
    "logstash_beats" = {
      from_port   = 5044
      to_port     = 5044
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr] # Allow from anywhere in VPC
    }
    "logstash_api" = {
      from_port   = 9600
      to_port     = 9600
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr] # Logstash monitoring API
    }
  }

  egress_rules = {
    "all_outbound" = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  depends_on = [module.networking, module.bastion]
}