# CloudWatch Alarms for per-domain Delta Lake metrics → SNS → Slack

locals {
  # Effective threshold per domain: domain-level override → module default → null (alarm disabled).
  # A domain is included only when it is enabled and an effective threshold is non-null.
  domain_compaction_debt_thresholds = {
    for k, v in var.domain_schedules : k => coalesce(
      try(v.alert_thresholds.max_compaction_debt, null),
      var.default_max_compaction_debt_alert_threshold
    )
    if v.enabled && (
      try(v.alert_thresholds.max_compaction_debt, null) != null ||
      var.default_max_compaction_debt_alert_threshold != null
    )
  }

  effective_sns_topic_arn = var.slack_alerts_sns_topic_arn

}

# ---------------------------------------------------------------------------
# One CloudWatch Alarm per domain (where enabled and threshold is non-null)
# ---------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "max_compaction_debt" {
  for_each = var.enable ? local.domain_compaction_debt_thresholds : {}

  alarm_name        = "${var.name}-${each.key}-max-compaction-debt"
  alarm_description = "MaxCompactionDebt for domain ${each.key} exceeds threshold ${each.value}"

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "MaxCompactionDebt"
  namespace           = "DPRAgentCustomMetrics"

  # 24 hours — aligns with the default 3×-daily schedule. Adjust per-domain if needed.
  period    = 86400
  statistic = "Maximum"
  threshold = each.value

  dimensions = {
    Domain  = each.key
    service = var.powertools_service_name
  }

  # Do not raise a false alarm for domains that haven't published a metric yet
  treat_missing_data = "notBreaching"

  alarm_actions = local.effective_sns_topic_arn != null ? [local.effective_sns_topic_arn] : []
  ok_actions    = local.effective_sns_topic_arn != null ? [local.effective_sns_topic_arn] : []

  tags = merge(var.tags, { alarm_type = "max-compaction-debt" })
}
