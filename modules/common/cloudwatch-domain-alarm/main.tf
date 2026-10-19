# Generic per-key CloudWatch metric alarm.
#
# Creates one aws_cloudwatch_metric_alarm per entry in var.thresholds.
# The caller is responsible for computing the threshold map and any
# per-key dimension values before calling this module.

resource "aws_cloudwatch_metric_alarm" "this" {
  for_each = var.enable ? var.thresholds : {}

  alarm_name        = var.alarm_name_suffix != "" ? "${var.alarm_name_prefix}-${each.key}-${var.alarm_name_suffix}" : "${var.alarm_name_prefix}-${each.key}"
  alarm_description = format(var.alarm_description_template, each.key)

  comparison_operator = var.comparison_operator
  evaluation_periods  = var.evaluation_periods
  metric_name         = var.metric_name
  namespace           = var.namespace
  period              = var.period
  statistic           = var.statistic
  threshold           = each.value

  dimensions = lookup(var.dimensions, each.key, {})

  treat_missing_data = var.treat_missing_data

  alarm_actions = var.sns_topic_arn != null ? [var.sns_topic_arn] : []
  ok_actions    = var.sns_topic_arn != null ? [var.sns_topic_arn] : []

  tags = var.tags
}
