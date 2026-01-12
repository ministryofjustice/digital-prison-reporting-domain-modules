# We will monitor log groups for messages containing certain strings that indicate errors, warnings, exceptions, etc.
locals {
  # The log groups we will monitor.
  log_groups_to_monitor = [
    aws_cloudwatch_log_group.job,
    aws_cloudwatch_log_group.sec_config,
    aws_cloudwatch_log_group.sec_config_output,
    aws_cloudwatch_log_group.sec_config_error
  ]

  # The signals in the logs we want to create metrics for
  signals_to_monitor = {
    exception = {
      # We exclude log messages that include "Exception" due to app startup classpath
      metric_name = "GlueJobExceptionCount"
      pattern     = "\"Exception\" -\"/usr/bin/java -cp\" -\"-Dspark.jars\" -\"/opt/amazon/lib/\""
    },
    warn = {
      metric_name = "WarnCount"
      pattern     = "\"WARN\""
    },
    error = {
      metric_name = "WarnCount"
      pattern     = "\"ERROR\""
    },
    fatal = {
      metric_name = "WarnCount"
      pattern     = "\"FATAL\""
    },
  }

  # Flatten the log_groups_to_monitor and signals_to_monitor maps so we can iterate over it easily
  filter_metrics = var.create_job ? {
    for item in flatten([
      for log_group in local.log_groups_to_monitor: [
        for signal, pattern_config in local.signals_to_monitor: {
          key = "${log_group}-${signal}"
          log_group_name = log_group.name
          signal = signal # e.g. exception, warn
          metric_name = pattern_config.metric_name
          pattern = pattern_config.pattern
        }
      ]
    ]): item.key => item
  }: {}
}

resource "aws_cloudwatch_log_metric_filter" "glue_exception_count" {
  for_each = local.filter_metrics

  name           = "GlueJob-${each.value.signal}-${replace(replace(each.value.log_group_name, "/", "_"), ":", "_")}"
  log_group_name = each.value.log_group_name
  pattern        = each.value.pattern

  metric_transformation {
    name      = each.value.metric_name
    namespace = var.custom_metric_namespace
    value     = "1"
  }
}
