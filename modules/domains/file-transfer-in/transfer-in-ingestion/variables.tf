variable "antivirus_check_lambda_arn" {
  type = string
}

variable "antivirus_trigger_bucket_arn" {
  description = "S3 Bucket ARN for the lambda trigger"
  type        = string
}

variable "bucket_prefix" {
  description = "The prefix used in S3 buckets for this domain, i.e. the prefix used when ingesting data and in the raw, structured, curated, etc. zones"
  type        = string
}
