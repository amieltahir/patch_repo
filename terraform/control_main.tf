# Reference the default VPC
data "aws_vpc" "default" {
  default = true
}

# Reference the default subnet in the default VPC
data "aws_subnet" "default_subnet" {
  vpc_id = data.aws_vpc.default.id
}

# Security Group for Control VM
resource "aws_security_group" "control_vm_security_group" {
  name        = "control_vm_security_group"
  description = "Allow necessary inbound traffic for control VM"
  vpc_id      = data.aws_vpc.default.id  # Using the default VPC

  # Allow SSH from Target VM
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH access from all sources"
  }

  # Allow HTTP from Target VM
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP access from all sources"
  }

  # Allow HTTPS from Target VM
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS access from all sources"
  }

  # Allow OpenVAS (9390) Web Interface
  ingress {
    from_port   = 9390
    to_port     = 9390
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow OpenVAS access from all sources"
  }

  # Allow Syslog (514 UDP) for log forwarding
  ingress {
    from_port   = 514
    to_port     = 514
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow syslog forwarding from all sources"
  }

  # Allow Prometheus (9090) scraping
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow Prometheus scraping from all sources"
  }

  # Allow Grafana (3000) Web Interface
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow Grafana access from all sources"
  }

  # Allow Lynis (SSH/Console only, no web UI)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow Lynis SSH/console access"
  }

  # Allow the Control VM to initiate outbound traffic to any destination
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "Control-VM-Security-Group"
  }
}

# EC2 instance for Control VM
resource "aws_instance" "control_vm" {
  ami           = "ami-0c02fb55956c7d316"  # Replace with a valid Ubuntu AMI
  instance_type = "t3.micro"
  key_name      = "control-key"
  subnet_id     = data.aws_subnet.default_subnet.id
  security_group_ids = [aws_security_group.control_vm_security_group.id]

  tags = {
    Name = "Control-VM"
  }

  # Ensure Control VM has Prometheus, Grafana, OpenVAS, and Lynis setup
  user_data = <<-EOF
              #!/bin/bash
              # Install Prometheus, Grafana, OpenVAS, and Lynis
              sudo apt update && sudo apt install -y prometheus grafana openvas lynis
              sudo systemctl enable prometheus
              sudo systemctl start prometheus
              sudo systemctl enable grafana-server
              sudo systemctl start grafana-server
              sudo systemctl enable openvas-scanner
              sudo systemctl start openvas-scanner
              sudo systemctl enable lynis
              sudo systemctl start lynis
              EOF
}
