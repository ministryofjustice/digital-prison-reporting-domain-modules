# Reload Pipeline Step Function Without Backfill
module "reload_pipeline" {
  source = "../../step_function"

  count = (var.setup_reload_pipeline && var.enable_archive_backfill == false) ? 1 : 0

  enable_step_function = var.setup_reload_pipeline
  step_function_name   = var.reload_pipeline
  dms_task_time_out    = var.pipeline_dms_task_time_out

  step_function_execution_role_arn = var.step_function_execution_role_arn

  definition = var.file_transfer_in ? jsonencode(
    {
      "Comment" : "Reload Pipeline Step Function (File Transfer In Batch Only)",
      "StartAt" : local.update_hive_tables.StepName,
      "States" : {
        (local.update_hive_tables.StepName) : local.update_hive_tables.StepDefinition,
        (local.prepare_temp_reload_bucket_data.StepName) : local.prepare_temp_reload_bucket_data.StepDefinition,
        (local.copy_curated_data_to_temp_reload_bucket.StepName) : local.copy_curated_data_to_temp_reload_bucket.StepDefinition,
        (local.switch_hive_tables_for_prisons_to_temp_reload_bucket.StepName) : local.switch_hive_tables_for_prisons_to_temp_reload_bucket.StepDefinition,
        (local.empty_landing_processing_raw_structured_and_curated_data.StepName) : local.empty_landing_processing_raw_structured_and_curated_data.StepDefinition,
        (local.invoke_landing_zone_antivirus_check_lambda.StepName) : local.invoke_landing_zone_antivirus_check_lambda.StepDefinition,
        (local.invoke_landing_zone_processing_lambda.StepName) : local.invoke_landing_zone_processing_lambda.StepDefinition,
        (local.run_glue_batch_job.StepName) : local.run_glue_batch_job.StepDefinition,
        (local.delete_existing_reload_diffs.StepName) : local.delete_existing_reload_diffs.StepDefinition,
        (local.run_create_reload_diff_batch_job.StepName) : local.run_create_reload_diff_batch_job.StepDefinition,
        (local.move_reload_diffs_toInsert_to_archive_bucket.StepName) : local.move_reload_diffs_toInsert_to_archive_bucket.StepDefinition,
        (local.move_reload_diffs_toDelete_to_archive_bucket.StepName) : local.move_reload_diffs_toDelete_to_archive_bucket.StepDefinition,
        (local.move_reload_diffs_toUpdate_to_archive_bucket.StepName) : local.move_reload_diffs_toUpdate_to_archive_bucket.StepDefinition,
        (local.empty_raw_data.StepName) : local.empty_raw_data.StepDefinition,
        (local.run_compaction_job_on_structured_zone.StepName) : local.run_compaction_job_on_structured_zone.StepDefinition,
        (local.run_vacuum_job_on_structured_zone.StepName) : local.run_vacuum_job_on_structured_zone.StepDefinition,
        (local.run_compaction_job_on_curated_zone.StepName) : local.run_compaction_job_on_curated_zone.StepDefinition,
        (local.run_vacuum_job_on_curated_zone.StepName) : local.run_vacuum_job_on_curated_zone.StepDefinition,
        (local.switch_hive_tables_for_prisons_to_curated.StepName) : local.switch_hive_tables_for_prisons_to_curated.StepDefinition,
        (local.empty_temp_reload_bucket_data.StepName) : local.empty_temp_reload_bucket_data.StepDefinition
      }
    }
    ) : var.batch_only ? jsonencode(
    {
      "Comment" : "Reload Pipeline Step Function (Batch Only)",
      "StartAt" : local.stop_dms_replication_task.StepName,
      "States" : {
        (local.stop_dms_replication_task.StepName) : local.stop_dms_replication_task.StepDefinition,
        (local.update_hive_tables.StepName) : local.update_hive_tables.StepDefinition,
        (local.prepare_temp_reload_bucket_data.StepName) : local.prepare_temp_reload_bucket_data.StepDefinition,
        (local.copy_curated_data_to_temp_reload_bucket.StepName) : local.copy_curated_data_to_temp_reload_bucket.StepDefinition,
        (local.switch_hive_tables_for_prisons_to_temp_reload_bucket.StepName) : local.switch_hive_tables_for_prisons_to_temp_reload_bucket.StepDefinition,
        (local.empty_raw_structured_and_curated_data.StepName) : local.empty_raw_structured_and_curated_data.StepDefinition,
        (local.start_dms_replication_task.StepName) : local.start_dms_replication_task.StepDefinition,
        (local.invoke_dms_state_control_lambda.StepName) : local.invoke_dms_state_control_lambda.StepDefinition,
        (local.run_glue_batch_job.StepName) : local.run_glue_batch_job.StepDefinition,
        (local.delete_existing_reload_diffs.StepName) : local.delete_existing_reload_diffs.StepDefinition,
        (local.run_create_reload_diff_batch_job.StepName) : local.run_create_reload_diff_batch_job.StepDefinition,
        (local.move_reload_diffs_toInsert_to_archive_bucket.StepName) : local.move_reload_diffs_toInsert_to_archive_bucket.StepDefinition,
        (local.move_reload_diffs_toDelete_to_archive_bucket.StepName) : local.move_reload_diffs_toDelete_to_archive_bucket.StepDefinition,
        (local.move_reload_diffs_toUpdate_to_archive_bucket.StepName) : local.move_reload_diffs_toUpdate_to_archive_bucket.StepDefinition,
        (local.empty_raw_data.StepName) : local.empty_raw_data.StepDefinition,
        (local.run_compaction_job_on_structured_zone.StepName) : local.run_compaction_job_on_structured_zone.StepDefinition,
        (local.run_vacuum_job_on_structured_zone.StepName) : local.run_vacuum_job_on_structured_zone.StepDefinition,
        (local.run_compaction_job_on_curated_zone.StepName) : local.run_compaction_job_on_curated_zone.StepDefinition,
        (local.run_vacuum_job_on_curated_zone.StepName) : local.run_vacuum_job_on_curated_zone.StepDefinition,
        (local.run_reconciliation_job.StepName) : local.run_reconciliation_job.StepDefinition,
        (local.switch_hive_tables_for_prisons_to_curated.StepName) : local.switch_hive_tables_for_prisons_to_curated.StepDefinition,
        (local.empty_temp_reload_bucket_data.StepName) : local.empty_temp_reload_bucket_data.StepDefinition
      }
    }
    ) : var.split_pipeline ? jsonencode(
    {
      "Comment" : "Reload Pipeline Step Function (With Separated Full-Load and CDC Tasks)",
      "StartAt" : local.deactivate_archive_trigger.StepName,
      "States" : {
        (local.deactivate_archive_trigger.StepName) : local.deactivate_archive_trigger.StepDefinition,
        (local.stop_archive_job.StepName) : local.stop_archive_job.StepDefinition,
        (local.stop_dms_cdc_replication_task.StepName) : local.stop_dms_cdc_replication_task.StepDefinition,
        (local.check_all_pending_files_have_been_processed.StepName) : local.check_all_pending_files_have_been_processed.StepDefinition,
        (local.stop_glue_streaming_job.StepName) : local.stop_glue_streaming_job.StepDefinition,
        (local.archive_remaining_raw_files.StepName) : local.archive_remaining_raw_files.StepDefinition,
        (local.update_hive_tables.StepName) : local.update_hive_tables.StepDefinition,
        (local.prepare_temp_reload_bucket_data.StepName) : local.prepare_temp_reload_bucket_data.StepDefinition,
        (local.copy_curated_data_to_temp_reload_bucket.StepName) : local.copy_curated_data_to_temp_reload_bucket.StepDefinition,
        (local.switch_hive_tables_for_prisons_to_temp_reload_bucket.StepName) : local.switch_hive_tables_for_prisons_to_temp_reload_bucket.StepDefinition,
        (local.empty_raw_structured_and_curated_data.StepName) : local.empty_raw_structured_and_curated_data.StepDefinition,
        (local.start_dms_replication_task.StepName) : local.start_dms_replication_task.StepDefinition,
        (local.invoke_dms_state_control_lambda.StepName) : local.invoke_dms_state_control_lambda.StepDefinition,
        (local.set_dms_cdc_replication_task_start_time.StepName) : local.set_dms_cdc_replication_task_start_time.StepDefinition,
        (local.run_glue_batch_job.StepName) : local.run_glue_batch_job.StepDefinition,
        (local.delete_existing_reload_diffs.StepName) : local.delete_existing_reload_diffs.StepDefinition,
        (local.run_create_reload_diff_batch_job.StepName) : local.run_create_reload_diff_batch_job.StepDefinition,
        (local.move_reload_diffs_toInsert_to_archive_bucket.StepName) : local.move_reload_diffs_toInsert_to_archive_bucket.StepDefinition,
        (local.move_reload_diffs_toDelete_to_archive_bucket.StepName) : local.move_reload_diffs_toDelete_to_archive_bucket.StepDefinition,
        (local.move_reload_diffs_toUpdate_to_archive_bucket.StepName) : local.move_reload_diffs_toUpdate_to_archive_bucket.StepDefinition,
        (local.empty_raw_data.StepName) : local.empty_raw_data.StepDefinition,
        (local.start_dms_cdc_replication_task.StepName) : local.start_dms_cdc_replication_task.StepDefinition,
        (local.start_glue_streaming_job.StepName) : local.start_glue_streaming_job.StepDefinition,
        (local.switch_hive_tables_for_prisons_to_curated.StepName) : local.switch_hive_tables_for_prisons_to_curated.StepDefinition,
        (local.reactivate_archive_trigger.StepName) : local.reactivate_archive_trigger.StepDefinition,
        (local.empty_temp_reload_bucket_data.StepName) : local.empty_temp_reload_bucket_data.StepDefinition
      }
    }
    ) : jsonencode(
    {
      "Comment" : "Reload Pipeline Step Function",
      "StartAt" : local.deactivate_archive_trigger.StepName,
      "States" : {
        (local.deactivate_archive_trigger.StepName) : local.deactivate_archive_trigger.StepDefinition,
        (local.stop_archive_job.StepName) : local.stop_archive_job.StepDefinition,
        (local.stop_dms_replication_task.StepName) : local.stop_dms_replication_task.StepDefinition,
        (local.check_all_pending_files_have_been_processed.StepName) : local.check_all_pending_files_have_been_processed.StepDefinition,
        (local.stop_glue_streaming_job.StepName) : local.stop_glue_streaming_job.StepDefinition,
        (local.archive_remaining_raw_files.StepName) : local.archive_remaining_raw_files.StepDefinition,
        (local.update_hive_tables.StepName) : local.update_hive_tables.StepDefinition,
        (local.prepare_temp_reload_bucket_data.StepName) : local.prepare_temp_reload_bucket_data.StepDefinition,
        (local.copy_curated_data_to_temp_reload_bucket.StepName) : local.copy_curated_data_to_temp_reload_bucket.StepDefinition,
        (local.switch_hive_tables_for_prisons_to_temp_reload_bucket.StepName) : local.switch_hive_tables_for_prisons_to_temp_reload_bucket.StepDefinition,
        (local.empty_raw_structured_and_curated_data.StepName) : local.empty_raw_structured_and_curated_data.StepDefinition,
        (local.start_dms_replication_task.StepName) : local.start_dms_replication_task.StepDefinition,
        (local.invoke_dms_state_control_lambda.StepName) : local.invoke_dms_state_control_lambda.StepDefinition,
        (local.run_glue_batch_job.StepName) : local.run_glue_batch_job.StepDefinition,
        (local.delete_existing_reload_diffs.StepName) : local.delete_existing_reload_diffs.StepDefinition,
        (local.run_create_reload_diff_batch_job.StepName) : local.run_create_reload_diff_batch_job.StepDefinition,
        (local.move_reload_diffs_toInsert_to_archive_bucket.StepName) : local.move_reload_diffs_toInsert_to_archive_bucket.StepDefinition,
        (local.move_reload_diffs_toDelete_to_archive_bucket.StepName) : local.move_reload_diffs_toDelete_to_archive_bucket.StepDefinition,
        (local.move_reload_diffs_toUpdate_to_archive_bucket.StepName) : local.move_reload_diffs_toUpdate_to_archive_bucket.StepDefinition,
        (local.empty_raw_data.StepName) : local.empty_raw_data.StepDefinition,
        (local.run_compaction_job_on_structured_zone.StepName) : local.run_compaction_job_on_structured_zone.StepDefinition,
        (local.run_vacuum_job_on_structured_zone.StepName) : local.run_vacuum_job_on_structured_zone.StepDefinition,
        (local.run_compaction_job_on_curated_zone.StepName) : local.run_compaction_job_on_curated_zone.StepDefinition,
        (local.run_vacuum_job_on_curated_zone.StepName) : local.run_vacuum_job_on_curated_zone.StepDefinition,
        (local.resume_dms_replication_task.StepName) : local.resume_dms_replication_task.StepDefinition,
        (local.start_glue_streaming_job.StepName) : local.start_glue_streaming_job.StepDefinition,
        (local.switch_hive_tables_for_prisons_to_curated.StepName) : local.switch_hive_tables_for_prisons_to_curated.StepDefinition,
        (local.reactivate_archive_trigger.StepName) : local.reactivate_archive_trigger.StepDefinition,
        (local.empty_temp_reload_bucket_data.StepName) : local.empty_temp_reload_bucket_data.StepDefinition
      }
    }
  )

  tags = var.tags

}


# Reload Pipeline Step Function With Archive Backfill
module "reload_pipeline_with_archive_backfill" {
  source = "../../step_function"

  count = (var.setup_reload_pipeline && var.enable_archive_backfill) ? 1 : 0

  enable_step_function = var.setup_reload_pipeline
  step_function_name   = var.reload_pipeline
  dms_task_time_out    = var.pipeline_dms_task_time_out

  step_function_execution_role_arn = var.step_function_execution_role_arn

  definition = var.batch_only ? jsonencode(
    {
      "Comment" : "Reload With Archive Backfill Pipeline Step Function (Batch Only)",
      "StartAt" : local.stop_dms_replication_task.StepName,
      "States" : {
        (local.stop_dms_replication_task.StepName) : local.stop_dms_replication_task.StepDefinition,
        (local.update_hive_tables.StepName) : local.update_hive_tables.StepDefinition,
        (local.delete_existing_backfill_data.StepName) : local.delete_existing_backfill_data.StepDefinition,
        (local.create_backfilled_archive_data.StepName) : local.create_backfilled_archive_data.StepDefinition,
        (local.empty_archive_data.StepName) : local.empty_archive_data.StepDefinition,
        (local.move_backfilled_data_to_archive_bucket.StepName) : local.move_backfilled_data_to_archive_bucket.StepDefinition,
        (local.prepare_temp_reload_bucket_data.StepName) : local.prepare_temp_reload_bucket_data.StepDefinition,
        (local.copy_curated_data_to_temp_reload_bucket.StepName) : local.copy_curated_data_to_temp_reload_bucket.StepDefinition,
        (local.switch_hive_tables_for_prisons_to_temp_reload_bucket.StepName) : local.switch_hive_tables_for_prisons_to_temp_reload_bucket.StepDefinition,
        (local.empty_raw_structured_and_curated_data.StepName) : local.empty_raw_structured_and_curated_data.StepDefinition,
        (local.start_dms_replication_task.StepName) : local.start_dms_replication_task.StepDefinition,
        (local.invoke_dms_state_control_lambda.StepName) : local.invoke_dms_state_control_lambda.StepDefinition,
        (local.run_glue_batch_job.StepName) : local.run_glue_batch_job.StepDefinition,
        (local.delete_existing_reload_diffs.StepName) : local.delete_existing_reload_diffs.StepDefinition,
        (local.run_create_reload_diff_batch_job.StepName) : local.run_create_reload_diff_batch_job.StepDefinition,
        (local.move_reload_diffs_toInsert_to_archive_bucket.StepName) : local.move_reload_diffs_toInsert_to_archive_bucket.StepDefinition,
        (local.move_reload_diffs_toDelete_to_archive_bucket.StepName) : local.move_reload_diffs_toDelete_to_archive_bucket.StepDefinition,
        (local.move_reload_diffs_toUpdate_to_archive_bucket.StepName) : local.move_reload_diffs_toUpdate_to_archive_bucket.StepDefinition,
        (local.empty_raw_data.StepName) : local.empty_raw_data.StepDefinition,
        (local.run_compaction_job_on_structured_zone.StepName) : local.run_compaction_job_on_structured_zone.StepDefinition,
        (local.run_vacuum_job_on_structured_zone.StepName) : local.run_vacuum_job_on_structured_zone.StepDefinition,
        (local.run_compaction_job_on_curated_zone.StepName) : local.run_compaction_job_on_curated_zone.StepDefinition,
        (local.run_vacuum_job_on_curated_zone.StepName) : local.run_vacuum_job_on_curated_zone.StepDefinition,
        (local.run_reconciliation_job.StepName) : local.run_reconciliation_job.StepDefinition,
        (local.switch_hive_tables_for_prisons_to_curated.StepName) : local.switch_hive_tables_for_prisons_to_curated.StepDefinition,
        (local.empty_temp_reload_bucket_data.StepName) : local.empty_temp_reload_bucket_data.StepDefinition
      }
    }
    ) : var.split_pipeline ? jsonencode(
    {
      "Comment" : "Reload With Archive Backfill Pipeline Step Function (With Separated Full-Load and CDC Tasks)",
      "StartAt" : local.deactivate_archive_trigger.StepName,
      "States" : {
        (local.deactivate_archive_trigger.StepName) : local.deactivate_archive_trigger.StepDefinition,
        (local.stop_archive_job.StepName) : local.stop_archive_job.StepDefinition,
        (local.stop_dms_cdc_replication_task.StepName) : local.stop_dms_cdc_replication_task.StepDefinition,
        (local.check_all_pending_files_have_been_processed.StepName) : local.check_all_pending_files_have_been_processed.StepDefinition,
        (local.stop_glue_streaming_job.StepName) : local.stop_glue_streaming_job.StepDefinition,
        (local.archive_remaining_raw_files.StepName) : local.archive_remaining_raw_files.StepDefinition,
        (local.update_hive_tables.StepName) : local.update_hive_tables.StepDefinition,
        (local.delete_existing_backfill_data.StepName) : local.delete_existing_backfill_data.StepDefinition,
        (local.create_backfilled_archive_data.StepName) : local.create_backfilled_archive_data.StepDefinition,
        (local.empty_archive_data.StepName) : local.empty_archive_data.StepDefinition,
        (local.move_backfilled_data_to_archive_bucket.StepName) : local.move_backfilled_data_to_archive_bucket.StepDefinition,
        (local.prepare_temp_reload_bucket_data.StepName) : local.prepare_temp_reload_bucket_data.StepDefinition,
        (local.copy_curated_data_to_temp_reload_bucket.StepName) : local.copy_curated_data_to_temp_reload_bucket.StepDefinition,
        (local.switch_hive_tables_for_prisons_to_temp_reload_bucket.StepName) : local.switch_hive_tables_for_prisons_to_temp_reload_bucket.StepDefinition,
        (local.empty_raw_structured_and_curated_data.StepName) : local.empty_raw_structured_and_curated_data.StepDefinition,
        (local.start_dms_replication_task.StepName) : local.start_dms_replication_task.StepDefinition,
        (local.invoke_dms_state_control_lambda.StepName) : local.invoke_dms_state_control_lambda.StepDefinition,
        (local.set_dms_cdc_replication_task_start_time.StepName) : local.set_dms_cdc_replication_task_start_time.StepDefinition,
        (local.run_glue_batch_job.StepName) : local.run_glue_batch_job.StepDefinition,
        (local.delete_existing_reload_diffs.StepName) : local.delete_existing_reload_diffs.StepDefinition,
        (local.run_create_reload_diff_batch_job.StepName) : local.run_create_reload_diff_batch_job.StepDefinition,
        (local.move_reload_diffs_toInsert_to_archive_bucket.StepName) : local.move_reload_diffs_toInsert_to_archive_bucket.StepDefinition,
        (local.move_reload_diffs_toDelete_to_archive_bucket.StepName) : local.move_reload_diffs_toDelete_to_archive_bucket.StepDefinition,
        (local.move_reload_diffs_toUpdate_to_archive_bucket.StepName) : local.move_reload_diffs_toUpdate_to_archive_bucket.StepDefinition,
        (local.empty_raw_data.StepName) : local.empty_raw_data.StepDefinition,
        (local.start_dms_cdc_replication_task.StepName) : local.start_dms_cdc_replication_task.StepDefinition,
        (local.start_glue_streaming_job.StepName) : local.start_glue_streaming_job.StepDefinition,
        (local.switch_hive_tables_for_prisons_to_curated.StepName) : local.switch_hive_tables_for_prisons_to_curated.StepDefinition,
        (local.reactivate_archive_trigger.StepName) : local.reactivate_archive_trigger.StepDefinition,
        (local.empty_temp_reload_bucket_data.StepName) : local.empty_temp_reload_bucket_data.StepDefinition
      }
    }
    ) : jsonencode(
    {
      "Comment" : "Reload With Archive Backfill Pipeline Step Function",
      "StartAt" : local.deactivate_archive_trigger.StepName,
      "States" : {
        (local.deactivate_archive_trigger.StepName) : local.deactivate_archive_trigger.StepDefinition,
        (local.stop_archive_job.StepName) : local.stop_archive_job.StepDefinition,
        (local.stop_dms_replication_task.StepName) : local.stop_dms_replication_task.StepDefinition,
        (local.check_all_pending_files_have_been_processed.StepName) : local.check_all_pending_files_have_been_processed.StepDefinition,
        (local.stop_glue_streaming_job.StepName) : local.stop_glue_streaming_job.StepDefinition,
        (local.archive_remaining_raw_files.StepName) : local.archive_remaining_raw_files.StepDefinition,
        (local.update_hive_tables.StepName) : local.update_hive_tables.StepDefinition,
        (local.delete_existing_backfill_data.StepName) : local.delete_existing_backfill_data.StepDefinition,
        (local.create_backfilled_archive_data.StepName) : local.create_backfilled_archive_data.StepDefinition,
        (local.empty_archive_data.StepName) : local.empty_archive_data.StepDefinition,
        (local.move_backfilled_data_to_archive_bucket.StepName) : local.move_backfilled_data_to_archive_bucket.StepDefinition,
        (local.prepare_temp_reload_bucket_data.StepName) : local.prepare_temp_reload_bucket_data.StepDefinition,
        (local.copy_curated_data_to_temp_reload_bucket.StepName) : local.copy_curated_data_to_temp_reload_bucket.StepDefinition,
        (local.switch_hive_tables_for_prisons_to_temp_reload_bucket.StepName) : local.switch_hive_tables_for_prisons_to_temp_reload_bucket.StepDefinition,
        (local.empty_raw_structured_and_curated_data.StepName) : local.empty_raw_structured_and_curated_data.StepDefinition,
        (local.start_dms_replication_task.StepName) : local.start_dms_replication_task.StepDefinition,
        (local.invoke_dms_state_control_lambda.StepName) : local.invoke_dms_state_control_lambda.StepDefinition,
        (local.run_glue_batch_job.StepName) : local.run_glue_batch_job.StepDefinition,
        (local.delete_existing_reload_diffs.StepName) : local.delete_existing_reload_diffs.StepDefinition,
        (local.run_create_reload_diff_batch_job.StepName) : local.run_create_reload_diff_batch_job.StepDefinition,
        (local.move_reload_diffs_toInsert_to_archive_bucket.StepName) : local.move_reload_diffs_toInsert_to_archive_bucket.StepDefinition,
        (local.move_reload_diffs_toDelete_to_archive_bucket.StepName) : local.move_reload_diffs_toDelete_to_archive_bucket.StepDefinition,
        (local.move_reload_diffs_toUpdate_to_archive_bucket.StepName) : local.move_reload_diffs_toUpdate_to_archive_bucket.StepDefinition,
        (local.empty_raw_data.StepName) : local.empty_raw_data.StepDefinition,
        (local.run_compaction_job_on_structured_zone.StepName) : local.run_compaction_job_on_structured_zone.StepDefinition,
        (local.run_vacuum_job_on_structured_zone.StepName) : local.run_vacuum_job_on_structured_zone.StepDefinition,
        (local.run_compaction_job_on_curated_zone.StepName) : local.run_compaction_job_on_curated_zone.StepDefinition,
        (local.run_vacuum_job_on_curated_zone.StepName) : local.run_vacuum_job_on_curated_zone.StepDefinition,
        (local.resume_dms_replication_task.StepName) : local.resume_dms_replication_task.StepDefinition,
        (local.start_glue_streaming_job.StepName) : local.start_glue_streaming_job.StepDefinition,
        (local.switch_hive_tables_for_prisons_to_curated.StepName) : local.switch_hive_tables_for_prisons_to_curated.StepDefinition,
        (local.reactivate_archive_trigger.StepName) : local.reactivate_archive_trigger.StepDefinition,
        (local.empty_temp_reload_bucket_data.StepName) : local.empty_temp_reload_bucket_data.StepDefinition
      }
    }
  )

  tags = var.tags

}
