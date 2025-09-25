output "lambda_api_url" {
  description = "The API Gateway endpoint URL for the Lambda app"
  value       = module.lambda.api_invoke_url
}
