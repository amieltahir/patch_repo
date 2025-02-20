# control_vm.tf

resource "aws_instance" "control_vm" {
  ami           = "ami-12345678"  # Replace with a valid Ubuntu AMI
  instance_type = "t2.micro"
  key_name      = "your-key-name"  # Replace with your SSH key name
  subnet_id     = aws_subnet.subnet.id
  security_group_ids = [aws_security_group.control_vm_security_group.id]

  tags = {
    Name = "Control-VM"
  }

  # Ensure Control VM has Prometheus and Grafana setup
  user_data = <<-EOF
              #!/bin/bash
              # Install Prometheus and Grafana
              sudo apt update && sudo apt install -y prometheus grafana
              sudo systemctl enable prometheus
              sudo systemctl start prometheus
              sudo systemctl enable grafana-server
              sudo systemctl start grafana-server
              EOF
}

# Output the public IP of the Control VM
output "control_vm_ip" {
  value = aws_instance.control_vm.public_ip
}

# Security Group for Control VM
resource "aws_security_group" "control_vm_security_group" {
  name        = "control_vm_security_group"
  description = "Allow necessary inbound traffic for control VM"
  vpc_id      = aws_vpc.default.id  # Using the default VPC

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

  # Allow Nessus (8834) Web Interface
  ingress {
    from_port   = 8834
    to_port     = 8834
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow Nessus access from all sources"
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
