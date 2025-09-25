provider "aws" {
  region = var.aws_region
}

module "lambda" {
  source         = "./modules/lambda"
  function_name  = var.lambda_function_name
  ecr_image_uri  = var.existing_ecr_image_uri
  database_url   = var.database_url
}
