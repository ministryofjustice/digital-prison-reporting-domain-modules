variable "setup_transfer_in_ingestion" {
  description = "Whether to setup the resources for Transfer in Ingestion"
  type        = bool
  default     = false
}

variable "antivirus_check_lambda_arn" {
  type = string
}

variable "antivirus_trigger_bucket_name" {
  description = "S3 Bucket name for the lambda trigger"
  type        = string
}

variable "bucket_prefix" {
  description = "The prefix used in S3 buckets for this domain, i.e. the prefix used when ingesting data and in the raw, structured, curated, etc. zones"
  type        = string
}
