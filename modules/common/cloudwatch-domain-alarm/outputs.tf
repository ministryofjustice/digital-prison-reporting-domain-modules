output "alarm_arns" {
  description = "Map of alarm key to the ARN of the created CloudWatch alarm."
  value       = { for k, v in aws_cloudwatch_metric_alarm.this : k => v.arn }
}
