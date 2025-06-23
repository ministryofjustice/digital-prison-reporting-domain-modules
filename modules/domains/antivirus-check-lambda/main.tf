module "landing_zone_antivirus_check_lambda" {
  source = "git::https://github.com/ministryofjustice/modernisation-platform-environments.git//terraform/environments/digital-prison-reporting/modules/lambdas/container-image?ref=main"

  enable_lambda      = var.enable
  image_uri          = "${var.ecr_repository_url}:${var.image_version}"
  name               = var.name
  tracing            = "Active"
  lambda_trigger     = true
  trigger_bucket_arn = var.trigger_bucket_arn
  policies           = var.policies

  memory_size                    = var.memory_size
  timeout                        = var.timeout
  ephemeral_storage_size         = var.ephemeral_storage_size # Can be increased up to 10240MB if required
  reserved_concurrent_executions = var.reserved_concurrent_executions
  log_retention_in_days          = var.log_retention_in_days

  env_vars = {
    S3_OUTPUT_BUCKET_PATH     = "s3://${var.output_bucket_name}"
    S3_QUARANTINE_BUCKET_PATH = "s3://${var.quarantine_bucket_name}"
  }

  vpc_settings = {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  tags = merge(
    var.tags,
    {
      Name          = var.name
      Resource_Type = "Lambda"
      Jira          = "DPR2-1499"
    }
  )
}

# Each prefix in the S3 landing bucket needs to trigger the antivirus check lambda
resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
  count = var.enable ? 1 : 0

  bucket = var.antivirus_trigger_bucket_name

  dynamic "lambda_function" {
    for_each = var.bucket_prefixes
    content {
      lambda_function_arn = module.landing_zone_antivirus_check_lambda.lambda_function_arn
      events              = ["s3:ObjectCreated:*"]
      filter_prefix       = lambda_function.value
    }
  }

  depends_on = [module.landing_zone_antivirus_check_lambda.lambda_function_arn]
}
