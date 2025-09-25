variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "lambda_function_name" {
  type    = string
  default = "teamavail-app"
}

variable "existing_ecr_image_uri" {
  type    = string
  default = "654654545585.dkr.ecr.us-east-1.amazonaws.com/mario/konecta:latest"
}

variable "database_url" {
  type = string
}
