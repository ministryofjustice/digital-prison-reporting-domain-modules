output "schedule_arn" {
  description = "The ARN of the created EventBridge schedule, if enabled."
  value       = try(aws_scheduler_schedule.schedule[0].arn, null)
}

output "schedule_name" {
  description = "The name of the created EventBridge schedule, if enabled."
  value       = try(aws_scheduler_schedule.schedule[0].name, null)
}
