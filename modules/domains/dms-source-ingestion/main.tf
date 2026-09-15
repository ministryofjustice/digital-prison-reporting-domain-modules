module "dms_core" {
  source = "github.com/ministryofjustice/terraform-aws-moj-data-factory-modules//modules/database-migration-service/modules/dms-core?ref=ed4375b4eeea119248c7a143e8d64a692ff2c600"

  name   = var.name
  vpc_id = var.vpc_id

  replication_instance = {
    replication_instance_id      = "${var.name}-instance-${var.env}"
    replication_instance_class   = var.replication_instance_class
    allocated_storage            = var.replication_instance_storage
    engine_version               = var.replication_instance_version
    subnet_ids                   = var.subnet_ids
    multi_az                     = var.replication_instance_multi_az
    apply_immediately            = var.replication_instance_apply_immediately
    auto_minor_version_upgrade   = var.replication_instance_auto_minor_version_upgrade
    preferred_maintenance_window = var.replication_instance_maintenance_window
  }

  source_endpoint = {
    endpoint_id = "${var.project_id}-dms-${var.short_name}-${var.dms_source_name}-source-endpoint"
    engine_name = var.source_engine_name

    database_name = var.source_db_name

    secrets_manager_arn             = var.source_secrets_manager_arn
    secrets_manager_access_role_arn = var.source_secrets_manager_access_role_arn
    secrets_manager_kms_key_arn     = var.source_secrets_manager_kms_key_arn

    ssl_mode                    = var.source_ssl_mode
    extra_connection_attributes = var.source_extra_connection_attributes

    postgres_settings = var.source_engine_name == "postgres" ? {
      map_boolean_as_boolean       = var.source_postgres_map_boolean_as_boolean
      fail_tasks_on_lob_truncation = var.source_postgres_fail_tasks_on_lob_truncation
      heartbeat_enable             = var.source_postgres_heartbeat_enable
      heartbeat_frequency          = var.source_postgres_heartbeat_frequency
    } : null

    oracle_settings = var.source_engine_name == "oracle" && var.source_oracle_asm_secret_arn != null ? {
      secrets_manager_oracle_asm_secret_arn  = var.source_oracle_asm_secret_arn
      secrets_manager_oracle_asm_kms_key_arn = var.source_oracle_asm_kms_key_arn
    } : null
  }

  s3_target_endpoint = {
    endpoint_id             = "${var.project_id}-dms-${var.short_name}-s3-target-endpoint"
    bucket_name             = var.target_bucket_name
    service_access_role_arn = var.target_service_access_role_arn

    data_format                      = "parquet"
    cdc_max_batch_interval           = var.s3_cdc_max_batch_interval
    cdc_path                         = var.s3_cdc_path
    max_file_size                    = var.s3_max_file_size
    include_op_for_full_load         = true
    parquet_timestamp_in_millisecond = false
    timestamp_column_name            = "_timestamp"
  }

  replication_tasks = var.replication_tasks

  tags = var.tags
}
