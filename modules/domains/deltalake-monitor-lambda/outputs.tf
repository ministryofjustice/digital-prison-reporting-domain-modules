output "lambda_function_arn" {
  value = module.deltalake_monitor_lambda.lambda_function
}

output "lambda_name" {
  description = "The name of the Lambda function"
  value       = var.enable ? module.deltalake_monitor_lambda.lambda_name : ""
}

output "log_group_name" {
  description = "The lambda's log group."
  value       = local.monitor_log_group
}

output "domain_schedule_arns" {
  description = "Map of domain name to the ARN of its EventBridge schedule."
  value       = { for k, m in module.deltalake_monitor_schedule : k => m.schedule_arn }
}

output "slack_alerts_sns_topic_arn" {
  description = "ARN of the existing SNS topic used for Delta Lake Monitor alerts."
  value       = var.slack_alerts_sns_topic_arn
}
