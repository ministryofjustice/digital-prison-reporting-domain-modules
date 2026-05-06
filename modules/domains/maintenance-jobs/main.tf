# tflint-ignore-file: terraform_required_version, terraform_required_providers
# Glue Job, Delta Compaction Job
module "glue_delta_compaction_job" {
  source                        = "../../glue_job"
  create_job                    = var.create_compaction_job
  create_role                   = var.create_compaction_job_role
  name                          = var.compaction_job_name
  short_name                    = var.compaction_job_short_name
  command_type                  = "glueetl"
  glue_version                  = var.glue_version
  description                   = "Reconciles data across DataHub.\nArguments:\n--dpr.config.key: (Required) config key e.g. prisoner\n--dpr.dms.replication.task.id: (Required) ID of the DMS replication task to reconcile against the raw zone\n--dpr.reconciliation.checks.to.run: (Optional) Allows restricting the set of checks that will be run"
  create_security_configuration = var.create_sec_conf
  job_language                  = "scala"
  # Placeholder Script Location
  script_location  = "s3://${var.project_id}-artifact-store-${var.env}/build-artifacts/digital-prison-reporting-jobs/scripts/${var.script_file_version}"
  temp_dir         = var.temp_dir
  project_id       = var.project_id
  aws_kms_key      = var.s3_kms_arn
  spark_event_logs = var.spark_event_logs

  execution_class             = var.execution_class
  worker_type                 = var.compaction_job_worker_type
  number_of_workers           = var.compaction_job_num_workers
  max_concurrent              = var.max_concurrent_runs
  region                      = var.account_region
  account                     = var.account_id
  log_group_retention_in_days = var.log_group_retention_in_days
  additional_secret_arns      = var.additional_secret_arns
  enable_spark_ui             = var.enable_spark_ui

  tags = merge(
    var.tags,
    {
      Resource_Type = "Glue Job"
    }
  )

  arguments = var.glue_compaction_job_arguments
}

# Glue Job, Delta Retention (vacuum) Job
module "glue_delta_retention_job" {
  source                        = "./modules/glue_job"
  create_job                    = var.create_retention_job
  create_role                   = var.create_retention_job_role
  name                          = var.retention_job_name
  short_name                    = var.retention_job_short_name
  command_type                  = "glueetl"
  glue_version                  = var.glue_version
  description                   = "Runs the vacuum retention job on tables in the specified zone path.\nArguments:\n--dpr.maintenance.root.path: (Required) Root path on which to run the job.\n--dpr.domain.name: (Optional) The domain tables to include in the retention job. Will run for all tables if not specified.\n--dpr.config.s3.bucket: (Optional) The bucket in which the domain tables configs are located"
  create_security_configuration = var.create_sec_conf
  job_language                  = "scala"
  # Placeholder Script Location
  script_location  = "s3://${var.project_id}-artifact-store-${var.env}/build-artifacts/digital-prison-reporting-jobs/scripts/${var.script_file_version}"
  temp_dir         = var.temp_dir
  project_id       = var.project_id
  aws_kms_key      = var.s3_kms_arn
  spark_event_logs = var.spark_event_logs

  execution_class             = var.execution_class
  worker_type                 = var.retention_job_worker_type
  number_of_workers           = var.retention_job_num_workers
  max_concurrent              = var.max_concurrent_runs
  region                      = var.account_region
  account                     = var.account_id
  log_group_retention_in_days = var.log_group_retention_in_days
  additional_secret_arns      = var.additional_secret_arns
  enable_spark_ui             = var.enable_spark_ui

  tags = merge(
    var.tags,
    {
      Resource_Type = "Glue Job"
    }
  )

  arguments = var.glue_retention_job_arguments
}

