module "dms_core" {
  source = "github.com/ministryofjustice/terraform-aws-moj-data-factory-modules//modules/database-migration-service/modules/dms-core?ref=268b9f51e0e36f3a897cbdd5092751baa11e07b1"

  name   = var.name
  vpc_id = var.vpc_id

  replication_instance = {
    replication_instance_id      = "${var.name}-instance-${var.env}"
    replication_instance_class   = var.replication_instance_class
    allocated_storage            = var.replication_instance_storage
    engine_version               = var.replication_instance_version
    subnet_ids                   = var.subnet_ids
    multi_az                     = true
    apply_immediately            = true
    auto_minor_version_upgrade   = false
    preferred_maintenance_window = var.replication_instance_maintenance_window
  }

  source_endpoint = {
    endpoint_id = "${var.project_id}-dms-${var.short_name}-${var.dms_source_name}-source-endpoint"
    engine_name = var.source_engine_name

    database_name = var.source_db_name

    secrets_manager_arn             = var.source_secrets_manager_arn
    secrets_manager_access_role_arn = var.source_secrets_manager_access_role_arn
    secrets_manager_kms_key_arn = var.source_secrets_manager_kms_key_arn

    ssl_mode                    = var.source_ssl_mode
    extra_connection_attributes = var.source_extra_connection_attributes
  }

  s3_target_endpoint = {
    endpoint_id             = "${var.project_id}-dms-${var.short_name}-s3-target-endpoint"
    bucket_name             = var.target_bucket_name
    service_access_role_arn = var.target_service_access_role_arn

    data_format                      = "parquet"
    cdc_max_batch_interval           = var.s3_cdc_max_batch_interval
    include_op_for_full_load         = true
    parquet_timestamp_in_millisecond = false
    timestamp_column_name            = "_timestamp"
  }

  replication_tasks = var.replication_tasks

  tags = var.tags
}
