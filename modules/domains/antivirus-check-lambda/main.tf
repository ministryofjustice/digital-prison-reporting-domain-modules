module "landing_zone_antivirus_check_lambda" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  #checkov:skip=CKV_TF_2: "Ensure Terraform module sources use a tag with a version number"
  # tflint-ignore: terraform_module_pinned_source
  source = "git::https://github.com/ministryofjustice/modernisation-platform-environments.git//terraform/environments/digital-prison-reporting/modules/lambdas/container-image?ref=main"

  enable_lambda = var.enable
  image_uri     = "${var.ecr_repository_url}:${var.image_version}"
  name          = var.name
  tracing       = "Active"
  policies      = var.policies

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
