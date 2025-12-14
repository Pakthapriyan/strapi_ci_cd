variable "aws_region" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "ami_id" {
  default = "ami-0c1ac872a4eae2ee0"
}

variable "key_name" {
  default = "your-keypair-name"
}

variable "image_name" {}
variable "image_tag" {}

variable "admin_jwt_secret" {}
variable "app_keys" {}
variable "api_token_salt" {}

