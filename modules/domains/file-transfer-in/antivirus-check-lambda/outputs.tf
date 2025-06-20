output "lambda_function" {
  description = "The Lambda function"
  value       = module.landing_zone_antivirus_check_lambda.lambda_function
}
