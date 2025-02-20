provider "aws" {
  region = var.region
}

# Reference the customer's default VPC
data "aws_vpc" "default" {
  default = true
}

# Use the default VPC's ID
resource "aws_subnet" "main" {
  vpc_id                  = data.aws_vpc.default.id
  cidr_block              = var.subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
}

resource "aws_security_group" "control_vm_sg" {
  name        = "control-vm-sg"
  description = "Security group for control VM"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3100
    to_port     = 3100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "control_vm" {
  ami           = var.control_vm_ami
  instance_type = var.control_vm_type
  subnet_id     = aws_subnet.main.id
  security_groups = [aws_security_group.control_vm_sg.name]

  user_data = file("user_data.sh")

  tags = {
    Name = "control-vm"
  }
}

resource "aws_instance" "target_vms" {
  count         = length(var.target_vms)
  ami           = var.target_vm_ami
  instance_type = var.target_vm_type
  subnet_id     = aws_subnet.main.id
  security_groups = [aws_security_group.control_vm_sg.name]

  tags = {
    Name = "target-vm-${count.index}"
  }
}
