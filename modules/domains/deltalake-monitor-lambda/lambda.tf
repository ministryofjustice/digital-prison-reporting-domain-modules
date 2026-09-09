# Lambda that reads Delta Lake table metadata from the curated bucket and reports metrics

locals {
  curated_bucket_read_policy_name = "${var.name}-curated-bucket-read-policy"
  config_bucket_read_policy_name  = "${var.name}-config-bucket-read-policy"
  dms_describe_policy_name        = "${var.name}-dms-describe-policy"

  curated_bucket_read_policy_arn = "arn:aws:iam::${var.account}:policy/${local.curated_bucket_read_policy_name}"
  config_bucket_read_policy_arn  = "arn:aws:iam::${var.account}:policy/${local.config_bucket_read_policy_name}"
  dms_describe_policy_arn        = "arn:aws:iam::${var.account}:policy/${local.dms_describe_policy_name}"
}

# Read access to the curated bucket so the lambda can discover and read Delta Lake table data/metadata
resource "aws_iam_policy" "curated_bucket_read" {
  count = var.enable ? 1 : 0

  name = local.curated_bucket_read_policy_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
        ]
        Resource = "arn:aws:s3:::${var.curated_bucket_name}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
        ]
        Resource = "arn:aws:s3:::${var.curated_bucket_name}"
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
  policies      = concat(var.enable ? [local.curated_bucket_read_policy_arn, local.config_bucket_read_policy_arn, local.dms_describe_policy_arn] : [], var.policies)
  tracing       = var.lambda_tracing
  timeout       = var.lambda_timeout_in_seconds
  memory_size   = var.memory_size_mb

  env_vars = {
    CURATED_ZONE_S3_BUCKET = var.curated_bucket_name
    CONFIG_S3_BUCKET       = var.config_bucket_name
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

  depends_on = [aws_iam_policy.curated_bucket_read, aws_iam_policy.config_bucket_read, aws_iam_policy.dms_describe]
}
