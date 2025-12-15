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
  name        = "paktha-strapi-sg----1"
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
  key_name = "paktha-key"

  root_block_device {
    volume_size = 30
  }

user_data = <<EOF
#!/bin/bash
set -e

LOG=/var/log/strapi-userdata.log
exec > >(tee -a \$LOG) 2>&1

echo "==> Installing Docker"
yum install -y docker
systemctl enable docker
systemctl start docker

echo "==> Preparing app directory"
mkdir -p /home/ec2-user/strapi
cd /home/ec2-user/strapi

echo "==> Writing env file"
cat <<EOT > .env
HOST=0.0.0.0
PORT=1337
NODE_ENV=production
APP_KEYS=${var.app_keys}
API_TOKEN_SALT=${var.api_token_salt}
ADMIN_JWT_SECRET=${var.admin_jwt_secret}
EOT

echo "==> Docker login"
echo "${var.docker_password}" | docker login -u "${var.docker_username}" --password-stdin

echo "==> Pulling image"
docker pull ${var.image_name}:${var.image_tag}

echo "==> Starting Strapi"
docker rm -f strapi || true
docker run -d \
  --name strapi \
  --env-file /home/ec2-user/strapi/.env \
  -p 1337:1337 \
  --restart unless-stopped \
  ${var.image_name}:${var.image_tag}

echo "==> Done"
EOF



  tags = {
    Name = "paktha-strapi-task6"
  }
}

output "public_ip" {
  value = aws_instance.strapi.public_ip
}
