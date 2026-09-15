variable "name" {
  description = "DPR name for the source ingestion resources."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "name must be a non-empty string."
  }
}

variable "dms_source_name" {
  description = "Short source identifier used in DPR DMS endpoint naming, for example oracle or pgres."
  type        = string

  validation {
    condition     = length(trimspace(var.dms_source_name)) > 0
    error_message = "dms_source_name must be a non-empty string."
  }
}

variable "project_id" {
  description = "DPR project identifier."
  type        = string

  validation {
    condition     = length(trimspace(var.project_id)) > 0
    error_message = "project_id must be a non-empty string."
  }
}

variable "env" {
  description = "DPR environment."
  type        = string

  validation {
    condition     = length(trimspace(var.env)) > 0
    error_message = "env must be a non-empty string."
  }
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

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "subnet_ids must contain at least one subnet ID."
  }

  validation {
    condition     = alltrue([for subnet_id in var.subnet_ids : length(trimspace(subnet_id)) > 0])
    error_message = "subnet_ids must not contain empty subnet IDs."
  }
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

  validation {
    condition     = var.replication_instance_storage > 0
    error_message = "replication_instance_storage must be greater than zero."
  }
}

variable "replication_instance_maintenance_window" {
  description = "Preferred maintenance window for the DMS replication instance."
  type        = string
}

variable "replication_instance_multi_az" {
  description = "Whether the DMS replication instance is deployed across multiple Availability Zones."
  type        = bool
  default     = false
}

variable "replication_instance_apply_immediately" {
  description = "Whether modifications to the DMS replication instance are applied immediately rather than during the maintenance window."
  type        = bool
  default     = false
}

variable "replication_instance_auto_minor_version_upgrade" {
  description = "Whether minor DMS engine upgrades are applied automatically during the maintenance window."
  type        = bool
  default     = false
}

variable "source_engine_name" {
  description = "Source database engine. Supported DPR sources are Oracle and PostgreSQL."
  type        = string

  validation {
    condition     = contains(["oracle", "postgres"], var.source_engine_name)
    error_message = "source_engine_name must be either 'oracle' or 'postgres'."
  }
}

variable "source_db_name" {
  description = "Source database name."
  type        = string
}

variable "source_ssl_mode" {
  description = "SSL mode used by the DMS source endpoint. The caller must explicitly select the mode appropriate for the source."
  type        = string

  validation {
    condition = contains(
      ["none", "require", "verify-ca", "verify-full"],
      var.source_ssl_mode
    )
    error_message = "source_ssl_mode must be one of: none, require, verify-ca, verify-full."
  }
}

variable "source_extra_connection_attributes" {
  description = "Supported engine-specific DMS connection attributes."
  type        = string
  default     = null
}

variable "source_postgres_map_boolean_as_boolean" {
  description = "Whether PostgreSQL boolean values should be mapped as native booleans by DMS."
  type        = bool
  default     = true
}

variable "source_postgres_fail_tasks_on_lob_truncation" {
  description = "Whether PostgreSQL DMS tasks should fail when LOB data is truncated."
  type        = bool
  default     = true
}

variable "source_postgres_heartbeat_enable" {
  description = "Whether DMS WAL heartbeat is enabled for PostgreSQL sources to prevent inactive replication slots retaining old WAL."
  type        = bool
  default     = true
}

variable "source_postgres_heartbeat_frequency" {
  description = "PostgreSQL WAL heartbeat frequency in minutes."
  type        = number
  default     = 5

  validation {
    condition     = var.source_postgres_heartbeat_frequency > 0
    error_message = "source_postgres_heartbeat_frequency must be greater than zero."
  }
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

variable "source_secrets_manager_kms_key_arn" {
  description = "KMS key ARN used to decrypt the source database secret, where required."
  type        = string
  default     = null
}

variable "source_oracle_asm_secret_arn" {
  description = "Secrets Manager ARN containing Oracle ASM credentials for Binary Reader sources. Must only be supplied for Oracle sources that require ASM."
  type        = string
  default     = null

  validation {
    condition = (
      var.source_oracle_asm_secret_arn == null
      ||
      (
        var.source_engine_name == "oracle"
        &&
        length(trimspace(var.source_oracle_asm_secret_arn)) > 0
      )
    )

    error_message = "source_oracle_asm_secret_arn must be null or a non-empty string when source_engine_name is 'oracle'."
  }
}

variable "source_oracle_asm_kms_key_arn" {
  description = "KMS key ARN used to decrypt the Oracle ASM secret, where required. May only be supplied when an Oracle ASM secret is configured."
  type        = string
  default     = null

  validation {
    condition = (
      var.source_oracle_asm_kms_key_arn == null
      ||
      (
        var.source_engine_name == "oracle"
        &&
        var.source_oracle_asm_secret_arn != null
        &&
        length(trimspace(var.source_oracle_asm_kms_key_arn)) > 0
      )
    )

    error_message = "source_oracle_asm_kms_key_arn must be null or a non-empty string for an Oracle source with source_oracle_asm_secret_arn configured."
  }
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

  validation {
    condition     = var.s3_cdc_max_batch_interval > 0
    error_message = "s3_cdc_max_batch_interval must be greater than zero."
  }
}

variable "s3_cdc_path" {
  description = "Path within the DPR Raw S3 bucket where DMS writes CDC files."
  type        = string
  default     = "cdc"

  validation {
    condition     = length(trimspace(var.s3_cdc_path)) > 0
    error_message = "s3_cdc_path must be a non-empty string."
  }
}

variable "s3_max_file_size" {
  description = "Maximum DMS S3 output file size in KB."
  type        = number
  default     = 120000

  validation {
    condition     = var.s3_max_file_size >= 1 && var.s3_max_file_size <= 1048576
    error_message = "s3_max_file_size must be between 1 and 1048576 KB."
  }
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