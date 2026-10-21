variable "parent_domain" {
  description = "The parent domain a domain belongs to, which decides the Glue databases its tables are created in: prisons or probation"
  type        = string
  nullable    = false

  validation {
    condition     = contains(keys(local.databases), var.parent_domain)
    error_message = "parent_domain must be one of: prisons, probation"
  }
}
