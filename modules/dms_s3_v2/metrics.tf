resource "aws_cloudwatch_log_metric_filter" "dms_replication_instance_errors" {
  count = var.setup_dms_instance ? 1 : 0

  name           = "DMSTaskErrors"
  log_group_name = aws_cloudwatch_log_group.dms-instance-log-group[0].name
  # Patterns:
  # ]E: is the internal error marker, the equivalent of ERROR: or FATAL: in log4j and similar
  # FATAL/suspended are critical states
  pattern = "?\"]E:\" ?\"FATAL\" ?\"suspended\""

  metric_transformation {
    name      = "DMSErrorCount"
    namespace = var.custom_metric_namespace
    value     = "1"
    dimensions = {
      "ReplicationInstanceId" : aws_dms_replication_instance.dms-s3-target-instance[0].replication_instance_id
    }
  }
}

resource "aws_cloudwatch_log_metric_filter" "dms_replication_instance_warnings" {
  count = var.setup_dms_instance ? 1 : 0

  name           = "DMSTaskWarnings"
  log_group_name = aws_cloudwatch_log_group.dms-instance-log-group[0].name
  # Patterns:
  # ]W: is the internal DMS warning marker, the equivalent of WARN: in log4j and similar
  pattern = "\"]W:\""

  metric_transformation {
    name      = "DMSWarningCount"
    namespace = var.custom_metric_namespace
    value     = "1"
    dimensions = {
      "ReplicationInstanceId" : aws_dms_replication_instance.dms-s3-target-instance[0].replication_instance_id
    }
  }
}
