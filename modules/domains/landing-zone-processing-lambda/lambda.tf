# Lambda that takes CSV files form the Landing Processing Zone, converts them to Parquet and moves them to the Raw Zone
module "landing_zone_processing_lambda" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  #checkov:skip=CKV_TF_2: "Ensure Terraform module sources use a tag with a version number"
  # tflint-ignore: terraform_module_pinned_source
  source = "git::https://github.com/ministryofjustice/modernisation-platform-environments.git//terraform/environments/digital-prison-reporting/modules/lambdas/generic?ref=main"

  enable_lambda = var.enable
  name          = var.name
  s3_bucket     = var.lambda_code_s3_bucket
  s3_key        = var.lambda_code_s3_key
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  policies      = var.policies
  tracing       = var.lambda_tracing
  timeout       = var.lambda_timeout_in_seconds
  memory_size   = var.memory_size_mb

  env_vars = {
    OUTPUT_BUCKET                 = var.output_bucket_name
    SCHEMA_REGISTRY_BUCKET        = var.schema_registry_bucket_name
    VIOLATIONS_BUCKET             = var.violations_bucket_name
    VIOLATIONS_PATH               = var.violations_path
    CHARSET                       = var.csv_charset
    NUMBER_OF_HEADER_ROWS_TO_SKIP = var.number_of_csv_header_rows_to_skip
    LOG_CSV                       = var.log_csv
  }

  log_retention_in_days = var.lambda_log_retention_in_days

  vpc_settings = {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  tags = merge(
    var.tags,
    {
      Resource_Type = "Lambda"
      Name          = var.name
      Jira          = "DPR2-1499"
    }
  )
}
