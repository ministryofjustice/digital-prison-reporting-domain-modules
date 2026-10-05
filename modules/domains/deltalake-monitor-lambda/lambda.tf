# Lambda that reads Delta Lake table metadata from the structured bucket and reports metrics.
# It can also be run to diagnose troublesome tables, writing markdown reports to S3.

locals {
  structured_bucket_read_policy_name  = "${var.name}-strcutured-bucket-read-policy"
  config_bucket_read_policy_name      = "${var.name}-config-bucket-read-policy"
  dms_describe_policy_name            = "${var.name}-dms-describe-policy"
  report_modes_policy_name            = "${var.name}-report-modes-policy"

  structured_bucket_read_policy_arn = "arn:aws:iam::${var.account}:policy/${local.structured_bucket_read_policy_name}"
  config_bucket_read_policy_arn     = "arn:aws:iam::${var.account}:policy/${local.config_bucket_read_policy_name}"
  dms_describe_policy_arn           = "arn:aws:iam::${var.account}:policy/${local.dms_describe_policy_name}"
  report_modes_policy_arn           = "arn:aws:iam::${var.account}:policy/${local.report_modes_policy_name}"

  monitor_log_group = "/aws/lambda/${var.name}-function"

  report_s3_prefix = "deltalake-monitoring-reports"
}

# Read access to the structured bucket so the lambda can discover and read Delta Lake table data/metadata
resource "aws_iam_policy" "structured_bucket_read" {
  count = var.enable ? 1 : 0

  name = local.structured_bucket_read_policy_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
        ]
        Resource = "arn:aws:s3:::${var.structured_bucket_name}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
        ]
        Resource = "arn:aws:s3:::${var.structured_bucket_name}"
      },
    ]
  })
}

# Read access to the config bucket so the lambda can retrieve domain config files
resource "aws_iam_policy" "config_bucket_read" {
  count = var.enable ? 1 : 0

  name = local.config_bucket_read_policy_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
        ]
        Resource = "arn:aws:s3:::${var.config_bucket_name}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
        ]
        Resource = "arn:aws:s3:::${var.config_bucket_name}"
      },
    ]
  })
}

# Read-only access to the AWS DMS API so the lambda can work out which tables/paths are part of
# the domain it should look at in S3
resource "aws_iam_policy" "dms_describe" {
  count = var.enable ? 1 : 0

  name = local.dms_describe_policy_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dms:DescribeReplicationTasks",
          "dms:DescribeTableStatistics",
        ]
        Resource = "arn:aws:dms:${var.region}:${var.account}:*:*"
      },
    ]
  })
}

# Access needed only by the report modes:
#   - Glue: read a domain's CDC job settings as evidence for the diagnosis
#   - Bedrock: diagnose tables and summarise across them
#   - S3: write the markdown reports
#   - CloudWatch Logs Insights: find the worst tables in recent monitor-mode logs
resource "aws_iam_policy" "report_modes" {
  count = var.enable ? 1 : 0

  name = local.report_modes_policy_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadCdcGlueJobs"
        Effect = "Allow"
        Action = [
          "glue:GetJob",
        ]
        Resource = "arn:aws:glue:${var.region}:${var.account}:job/dpr-cdc-*-${var.environment}"
      },
      {
        Sid    = "InvokeBedrockModel"
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
        ]
        Resource = [
          "arn:aws:bedrock:${var.region}:${var.account}:inference-profile/${var.bedrock_model_id}",
          # A cross-region inference profile can route to the model in any EU region
          "arn:aws:bedrock:eu-*::foundation-model/${var.bedrock_foundation_model_id}",
        ]
      },
      {
        Sid    = "WriteReports"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
        ]
        Resource = "arn:aws:s3:::${var.report_s3_bucket_name}/${local.report_s3_prefix}/*"
      },
      {
        Sid    = "QueryMonitorLogs"
        Effect = "Allow"
        Action = [
          "logs:StartQuery",
        ]
        Resource = "arn:aws:logs:${var.region}:${var.account}:log-group:${local.monitor_log_group}:*"
      },
      {
        # These actions don't support resource-level permissions
        Sid    = "ReadQueryResults"
        Effect = "Allow"
        Action = [
          "logs:GetQueryResults",
          "logs:StopQuery",
        ]
        Resource = "*"
      },
    ]
  })
}

module "deltalake_monitor_lambda" {
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
  policies      = concat(var.enable ? [local.structured_bucket_read_policy_arn, local.config_bucket_read_policy_arn, local.dms_describe_policy_arn, local.report_modes_policy_arn] : [], var.policies)
  tracing       = var.lambda_tracing
  timeout       = var.lambda_timeout_in_seconds
  memory_size   = var.memory_size_mb

  env_vars = {
    STRUCTURED_ZONE_S3_BUCKET   = var.structured_bucket_name
    CONFIG_S3_BUCKET            = var.config_bucket_name
    S3_LIST_CUTOFF_FILE_COUNT   = tostring(var.s3_list_cutoff_file_count)
    S3_LIST_TIME_CUTOFF_SECONDS = tostring(var.s3_list_time_cutoff_seconds)
    # Only read by the report modes
    ENVIRONMENT       = var.environment
    REPORT_S3_BUCKET  = var.report_s3_bucket_name
    MONITOR_LOG_GROUP = local.monitor_log_group
    BEDROCK_MODEL_ID  = var.bedrock_model_id
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
    }
  )

  depends_on = [aws_iam_policy.structured_bucket_read, aws_iam_policy.config_bucket_read, aws_iam_policy.dms_describe, aws_iam_policy.report_modes]
}
