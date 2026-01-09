resource "aws_cloudwatch_log_metric_filter" "dms_replication_instance_errors" {
  count = var.setup_dms_instance ? 1 : 0

  name           = "DMSReplicationInstanceErrors-${aws_dms_replication_instance.dms-s3-target-instance[0].replication_instance_id}"
  log_group_name = aws_cloudwatch_log_group.dms-instance-log-group[0].name
  # ]E: is the internal error marker, the equivalent of ERROR: or FATAL: in log4j and similar
  pattern = "\"]E:\""


  metric_transformation {
    name      = "DMSErrorCount"
    namespace = var.custom_metric_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "dms_replication_instance_warnings" {
  count = var.setup_dms_instance ? 1 : 0

  name           = "DMSReplicationInstanceWarnings-${aws_dms_replication_instance.dms-s3-target-instance[0].replication_instance_id}"
  log_group_name = aws_cloudwatch_log_group.dms-instance-log-group[0].name
  # ]W: is the internal DMS warning marker, the equivalent of WARN: in log4j and similar
  # We exclude 'Unrecognized CDC record type' which is a noisy warn log line triggered by the heartbeat lambda
  pattern = "\"]W:\" -\"Unrecognized CDC record type\""

  metric_transformation {
    name      = "DMSWarningCount"
    namespace = var.custom_metric_namespace
    value     = "1"
  }
}
