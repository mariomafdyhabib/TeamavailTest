output "lambda_arn" {
  value = aws_lambda_function.this.arn
}

output "api_endpoint" {
  value = aws_apigatewayv2_api.api.api_endpoint
}

output "api_invoke_url" {
  description = "Invoke URL of the Lambda app via API Gateway"
  value       = "${aws_apigatewayv2_stage.default.invoke_url}"
}
