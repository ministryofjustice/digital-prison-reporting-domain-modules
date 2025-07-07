output "lambda_function_arn" {
  value = module.landing_zone_processing_lambda.lambda_function
}

output "lambda_name" {
  description = "The name of the Lambda function"
  value       = var.enable ? module.landing_zone_processing_lambda.lambda_name : ""
}
