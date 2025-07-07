output "lambda_name" {
  description = "The name of the Lambda function"
  value       = var.enable ? module.landing_zone_antivirus_check_lambda.lambda_name : ""
}
