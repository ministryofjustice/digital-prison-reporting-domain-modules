output "lambda_function_arn" {
  value = module.deltalake_monitor_lambda.lambda_function
}

output "lambda_name" {
  description = "The name of the Lambda function"
  value       = var.enable ? module.deltalake_monitor_lambda.lambda_name : ""
}
