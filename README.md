# akakinad-logstash-deployment
Secure Logstash deployment using Terraform and Ansible
# Logstash Deployment with Terraform and Ansible

A complete, automated, and secure Logstash deployment solution using Infrastructure as Code (IaC) principles. This project demonstrates enterprise-grade DevOps practices with modular Terraform infrastructure and Ansible configuration management.

## 🏗️ Architecture

```
Internet → Bastion Host (Public) → Logstash Server (Private) → [Future: Elasticsearch]
   🌐         🏰                      📊                         🔍
```

### Security Model
- **Bastion Host**: Secure gateway in public subnet with Elastic IP
- **Logstash Server**: Hidden in private subnet, accessible only through bastion
- **Network Isolation**: Private subnet with NAT gateway for outbound internet access
- **Firewall Rules**: Strict security groups limiting access by port and source

## 📁 Project Structure

```
akakinad-logstash-deployment/
├── terraform/                          # Infrastructure as Code
│   ├── main.tf                        # Root configuration - orchestrates modules
│   ├── variables.tf                   # Input variables and defaults
│   ├── outputs.tf                     # Infrastructure outputs (IPs, IDs)
│   ├── terraform.tfvars.example       # Configuration template
│   └── modules/                       # Reusable infrastructure components
│       ├── networking/                # VPC, subnets, gateways, routing
│       │   ├── main.tf               # Network infrastructure resources
│       │   ├── variables.tf          # Network configuration inputs
│       │   └── outputs.tf            # VPC and subnet IDs for other modules
│       └── compute/                   # EC2 instances and security groups
│           ├── main.tf               # Server and security group resources
│           ├── variables.tf          # Instance configuration inputs
│           └── outputs.tf            # Instance IDs and IPs
└── ansible/                           # Configuration Management
    ├── ansible.cfg                   # Ansible global configuration
    ├── playbook.yml                  # Main deployment orchestration
    ├── inventory/
    │   └── hosts.yml                 # Server inventory with bastion proxy config
    └── roles/
        └── logstash/                 # Logstash installation and configuration
            ├── tasks/main.yml        # Installation steps and service management
            ├── handlers/main.yml     # Service restart and validation handlers
            └── templates/
                ├── logstash.yml.j2   # Logstash main configuration template
                └── jvm.options.j2    # Java memory and performance settings
```

## 🎯 Features

### Infrastructure (Terraform)
- **Modular Design**: Reusable networking and compute modules
- **Security Best Practices**: Private subnets, security groups, least privilege access
- **High Availability**: Multi-AZ deployment capability
- **Cost Optimized**: t3.micro bastion, t3.medium Logstash server
- **Professional Tagging**: Consistent resource labeling and management

### Automation (Ansible)
- **Secure Connection**: SSH through bastion host proxy
- **Complete Installation**: Java 17 (Amazon Corretto) + Logstash 8.8.0
- **Production Configuration**: Optimized for AWS and t3.medium instances
- **Service Management**: Automatic startup, monitoring, and health checks
- **Configuration Validation**: Pre-deployment config testing

## 🚀 Prerequisites

### Tools Required
- **Terraform** >= 1.0
- **Ansible** >= 2.9
- **AWS CLI** configured with appropriate permissions
- **SSH key pair** (optional - can use EC2 Instance Connect)

### AWS Permissions Required
- EC2: Create/manage instances, security groups, key pairs
- VPC: Create/manage VPCs, subnets, gateways, route tables
- IAM: Create/manage roles and policies (minimal)

### Local Setup
```bash
# Install Terraform
brew install terraform

# Install Ansible
pip3 install ansible

# Verify installations
terraform --version
ansible --version
```

## 📋 Deployment Guide

### Step 1: Clone and Configure

```bash
git clone https://github.com/Akakinad/akakinad-logstash-deployment.git
cd akakinad-logstash-deployment
```

### Step 2: Configure Terraform

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your settings:
```hcl
# Get your IP from: https://whatismyipaddress.com/
my_ip = "YOUR-IP-ADDRESS/32"  # Replace with your actual IP

# Optional: Specify AWS profile if using named profiles
aws_profile = "your-aws-profile"

# Optional: Customize instance sizes
bastion_instance_type = "t3.micro"    # Cost-effective for bastion
logstash_instance_type = "t3.medium"  # Sufficient for log processing
```

### Step 3: Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review deployment plan
terraform plan

# Deploy infrastructure (requires appropriate AWS permissions)
terraform apply
```

**Important**: Save the outputs! You'll need the bastion public IP and Logstash private IP for Ansible.

### Step 4: Configure Ansible Inventory

After Terraform deployment, update the Ansible inventory with actual IP addresses:

```bash
cd ../ansible
```

Edit `inventory/hosts.yml` and replace:
- `BASTION_PUBLIC_IP` → Bastion Elastic IP from terraform output
- `LOGSTASH_PRIVATE_IP` → Logstash private IP from terraform output

Example:
```yaml
bastion-host:
  ansible_host: "54.123.45.67"  # Your bastion's Elastic IP

logstash-server:
  ansible_host: "10.0.10.123"   # Your Logstash private IP
  ansible_ssh_common_args: '-o ProxyCommand="ssh -o StrictHostKeyChecking=no -W %h:%p -q ec2-user@54.123.45.67"'
```

### Step 5: Deploy Logstash Configuration

```bash
# Test connectivity
ansible all -m ping

# Deploy Logstash (full automation)
ansible-playbook playbook.yml

# Or deploy only to Logstash servers
ansible-playbook playbook.yml --limit logstash
```

## 📊 Post-Deployment

### Verify Logstash Installation

```bash
# SSH to bastion host
ssh ec2-user@<BASTION_PUBLIC_IP>

# From bastion, SSH to Logstash server
ssh ec2-user@<LOGSTASH_PRIVATE_IP>

# Check Logstash status
sudo systemctl status logstash

# Check Logstash API
curl localhost:9600

# View logs
sudo tail -f /var/log/logstash/logstash-plain.log
```

### Test Log Processing

```bash
# Test Beats input (from Logstash server)
echo '{"message": "test log", "timestamp": "'$(date -Iseconds)'"}' | nc localhost 5044

# Check output file
sudo tail -f /var/log/logstash/output.log
```

## 🔧 Configuration

### Logstash Pipeline

The default pipeline configuration (`/etc/logstash/conf.d/main.conf`):
- **Input**: Beats on port 5044
- **Filter**: Basic processing with metadata addition
- **Output**: File output for testing (easily changed to Elasticsearch)

### Memory Configuration

Optimized for t3.medium (4GB RAM):
- **JVM Heap**: 1GB
- **Garbage Collector**: G1GC (optimized for AWS)
- **Performance Tuning**: String deduplication, optimized network timeouts

### Monitoring

- **Logstash API**: http://localhost:9600 (internal only)
- **Service Status**: `systemctl status logstash`
- **Logs**: `/var/log/logstash/`
- **Performance**: Built-in metrics collection enabled

## 🛠️ Troubleshooting

### Common Issues

**Terraform Issues:**
```bash
# Re-initialize if modules change
terraform init -upgrade

# Check AWS credentials
aws sts get-caller-identity

# Validate configuration
terraform validate
```

**Ansible Connectivity:**
```bash
# Test bastion connection
ansible bastion -m ping

# Test Logstash connection through bastion
ansible logstash -m ping

# Debug SSH connection
ssh -vvv ec2-user@<BASTION_IP>
```

**Logstash Issues:**
```bash
# Check service status
sudo systemctl status logstash

# Test configuration
sudo /usr/share/logstash/bin/logstash --config.test_and_exit --path.settings /etc/logstash

# Check logs
sudo journalctl -u logstash -f
```

### Performance Tuning

For higher throughput, adjust in `inventory/hosts.yml`:
```yaml
logstash:
  vars:
    logstash_heap_size: "2g"              # Increase for more memory
    logstash_instance_type: "t3.large"    # Upgrade instance in terraform.tfvars
```

## 📈 Scaling and Extension

### Add Elasticsearch Output

Edit `/etc/logstash/conf.d/main.conf`:
```ruby
output {
  elasticsearch {
    hosts => ["elasticsearch-host:9200"]
    index => "logstash-%{+YYYY.MM.dd}"
  }
}
```

### Multiple Logstash Nodes

1. Update Terraform to create multiple instances
2. Add load balancer for Beats input
3. Configure shared persistent queue

### Monitoring Integration

- **Beats**: Install Filebeat/Metricbeat for log shipping
- **Kibana**: Visualize logs and metrics
- **CloudWatch**: AWS native monitoring integration

## 🏷️ Resource Tagging

All resources are consistently tagged:
- **Project**: akakinad-logstash-deployment
- **ManagedBy**: Terraform
- **Owner**: akakinad
- **Environment**: dev
- **Purpose**: Learning-DevOps

## 💰 Cost Optimization

**Estimated Monthly Costs (us-west-2):**
- Bastion (t3.micro): ~$8
- Logstash (t3.medium): ~$30
- NAT Gateway: ~$32
- **Total**: ~$70/month

**Cost Reduction Options:**
- Use smaller instances for testing
- Stop instances when not in use
- Consider NAT instance instead of NAT Gateway

## 🤝 Contributing

This project follows infrastructure as code best practices:
- All changes via Terraform/Ansible
- Version controlled configuration
- Modular, reusable components
- Comprehensive documentation

## 📄 License

MIT License - see LICENSE file for details.

## 👨‍💻 Author

**akakinad** - DevOps Engineer  
Portfolio project demonstrating enterprise-grade infrastructure automation.

---

*Built with ❤️ using Terraform, Ansible, and AWS*