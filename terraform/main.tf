terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_security_group" "strapi_sg" {
  name = "strapi-sg"

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

resource "aws_instance" "strapi" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.key_name
  security_groups = [aws_security_group.strapi_sg.name]

user_data = <<EOF
#!/bin/bash
set -x

# Install Docker fast
yum update -y
amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker

# Run Strapi in background (do NOT block Terraform)
(
  docker stop strapi || true
  docker rm strapi || true
  docker pull ${var.image_name}:${var.image_tag}
  docker run -d \
    --name strapi \
    -p 1337:1337 \
    -e ADMIN_JWT_SECRET=${var.admin_jwt_secret} \
    -e APP_KEYS=${var.app_keys} \
    -e API_TOKEN_SALT=${var.api_token_salt} \
    ${var.image_name}:${var.image_tag}
) >/var/log/strapi-startup.log 2>&1 &

exit 0
EOF


}
