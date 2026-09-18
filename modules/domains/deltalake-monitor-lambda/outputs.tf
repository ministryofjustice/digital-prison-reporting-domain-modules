output "lambda_function_arn" {
  value = module.deltalake_monitor_lambda.lambda_function
}

output "lambda_name" {
  description = "The name of the Lambda function"
  value       = var.enable ? module.deltalake_monitor_lambda.lambda_name : ""
}

output "domain_schedule_arns" {
  description = "Map of domain name to the ARN of its EventBridge schedule."
  value       = { for k, m in module.deltalake_monitor_schedule : k => m.schedule_arn }
}
