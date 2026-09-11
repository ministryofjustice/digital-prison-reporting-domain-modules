module "dms_core" {
  source = "git::https://github.com/ministryofjustice/terraform-aws-moj-data-factory-modules.git//modules/database-migration-service/modules/dms-core?ref=integration/data-hub-modularisation"

  name   = var.name
  vpc_id = var.vpc_id

  security_group = {
    additional_vpc_security_group_ids = [
      aws_security_group.dms_source_ingestion.id
    ]
  }

  replication_instance = {
    replication_instance_id          = "${var.name}-instance-${var.env}"
    replication_instance_class       = var.replication_instance_class
    allocated_storage                = var.replication_instance_storage
    engine_version                   = var.replication_instance_version
    subnet_ids                       = var.subnet_ids
    multi_az                         = true
    apply_immediately                = true
    auto_minor_version_upgrade       = false
    preferred_maintenance_window     = var.replication_instance_maintenance_window
  }

  source_endpoint = {
    endpoint_id = "${var.name}-source"
    engine_name = var.source_engine_name

    database_name = var.source_db_name

    secrets_manager_arn             = var.source_secrets_manager_arn
    secrets_manager_access_role_arn = var.source_secrets_manager_access_role_arn

    ssl_mode                    = var.source_ssl_mode
    extra_connection_attributes = var.source_extra_connection_attributes
  }

  s3_target_endpoint = {
    endpoint_id             = "${var.name}-s3"
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