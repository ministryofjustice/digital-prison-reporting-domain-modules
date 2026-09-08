# Lambda that reads Delta Lake table metadata from the curated bucket and reports metrics

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# Read access to the curated bucket so the lambda can discover and read Delta Lake table data/metadata
resource "aws_iam_policy" "curated_bucket_read" {
  count = var.enable ? 1 : 0

  name = "${var.name}-curated-bucket-read-policy"
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

# Read-only access to the AWS DMS API so the lambda can work out which tables/paths are part of
# the domain it should look at in S3
resource "aws_iam_policy" "dms_describe" {
  count = var.enable ? 1 : 0

  name = "${var.name}-dms-describe-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dms:DescribeReplicationTasks",
          "dms:DescribeTableStatistics",
        ]
        Resource = "arn:aws:dms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*:*"
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
  policies      = concat(var.enable ? [aws_iam_policy.curated_bucket_read[0].arn, aws_iam_policy.dms_describe[0].arn] : [], var.policies)
  tracing       = var.lambda_tracing
  timeout       = var.lambda_timeout_in_seconds
  memory_size   = var.memory_size_mb

  env_vars = {
    CURATED_BUCKET = var.curated_bucket_name
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
}
