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

output "report_s3_prefix" {
  description = "Where the report modes write their markdown reports."
  value       = "s3://${var.report_s3_bucket_name}/${local.report_s3_prefix}/"
}

output "domain_schedule_arns" {
  description = "Map of domain name to the ARN of its EventBridge schedule."
  value       = { for k, m in module.deltalake_monitor_schedule : k => m.schedule_arn }
}
