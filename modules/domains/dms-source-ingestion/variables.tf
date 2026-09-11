variable "name" {
  description = "DPR name for the source ingestion resources."
  type        = string
}

variable "project_id" {
  description = "DPR project identifier."
  type        = string
}

variable "env" {
  description = "DPR environment."
  type        = string
}

variable "short_name" {
  description = "Short name used by existing DPR naming conventions."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags applied to source ingestion resources."
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC in which the DMS replication infrastructure is created."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs used by the DMS replication subnet group."
  type        = list(string)
}

variable "replication_instance_class" {
  description = "DMS replication instance class."
  type        = string
}

variable "replication_instance_version" {
  description = "DMS replication engine version."
  type        = string
}

variable "replication_instance_storage" {
  description = "Allocated storage for the DMS replication instance."
  type        = number
}

variable "replication_instance_maintenance_window" {
  description = "Preferred maintenance window for the DMS replication instance."
  type        = string
}

variable "source_engine_name" {
  description = "Source database engine. Supported DPR sources are Oracle and PostgreSQL."
  type        = string
}

variable "source_db_name" {
  description = "Source database name."
  type        = string
}

variable "source_ssl_mode" {
  description = "SSL mode used by the DMS source endpoint."
  type        = string
  default     = "none"
}

variable "source_extra_connection_attributes" {
  description = "Supported engine-specific DMS connection attributes."
  type        = string
  default     = null
}

variable "source_secrets_manager_arn" {
  description = "Secrets Manager ARN containing source database credentials."
  type        = string
}

variable "source_secrets_manager_access_role_arn" {
  description = "IAM role used by DMS to access the source database secret."
  type        = string
  default     = null
}

variable "target_bucket_name" {
  description = "DPR Raw S3 bucket used by the DMS target endpoint."
  type        = string
}

variable "target_service_access_role_arn" {
  description = "IAM role used by DMS to write to the target S3 bucket."
  type        = string
  default     = null
}

variable "s3_cdc_max_batch_interval" {
  description = "Maximum interval in seconds before DMS writes a CDC file to the DPR Raw S3 bucket."
  type        = number
  default     = 10
}

variable "replication_tasks" {
  description = "DPR DMS task definitions passed to the shared reusable DMS module."

  type = map(object({
    replication_task_id       = string
    migration_type            = string
    table_mappings            = string
    replication_task_settings = optional(string)
    tags                      = optional(map(string), {})
  }))

  default = {}
}