provider "aws" {
    region = "eu-central-1"
}

terraform {
  backend "s3" {
    bucket = "terraform-state-project-simple-server"
    key = "github/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "aws_ami" "latest_ubuntu_2204" {
    owners = ["099720109477"]
    most_recent = true
    filter {
      name = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }
}

resource "aws_instance" "simple-server" {
    ami = data.aws_ami.latest_ubuntu_2204.id
    instance_type = "t2.micro"

    tags = {
      "Name" = "simple-server"
      "Owner" = "Maksym Monakhov"
    }

    vpc_security_group_ids = [aws_security_group.simple-server.id]
    key_name = "4.monakhov"
}

resource "aws_security_group" "simple-server" {
  name = "simple-server-SG"
  
  dynamic "ingress" {
    for_each = ["22", "80", "443"]
    content {
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]  
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Ports for simple server project"
  }  
}

output "PUBLIC_IPV4" {
  value = aws_instance.simple-server.public_ip
}