variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

variable "image_name" {
  type = string
}

variable "image_tag" {
  type = string
}

variable "admin_jwt_secret" {
  type = string
}

variable "app_keys" {
  type = string
}

variable "api_token_salt" {
  type = string
}
