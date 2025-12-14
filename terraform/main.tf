terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "strapi_sg" {
  name        = "paktha-strapi-sg---"
  description = "Allow SSH and Strapi"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1337
    to_port     = 1337
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
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "strapi" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  security_groups = [aws_security_group.strapi_sg.name]

  root_block_device {
    volume_size = 30
  }

  user_data = <<EOF
#!/bin/bash
amazon-linux-extras install docker -y
systemctl enable docker
systemctl start docker

docker run -d -p 1337:1337 \
  -e ADMIN_JWT_SECRET=${var.admin_jwt_secret} \
  -e APP_KEYS=${var.app_keys} \
  -e API_TOKEN_SALT=${var.api_token_salt} \
  ${var.image_name}:${var.image_tag}
EOF

  tags = {
    Name = "paktha-strapi-task6"
  }
}

output "public_ip" {
  value = aws_instance.strapi.public_ip
}
