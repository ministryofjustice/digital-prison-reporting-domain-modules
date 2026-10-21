output "raw_archive_database" {
  description = "The Glue database for the domain's Raw Archive tables"
  value       = local.databases[var.parent_domain].raw_archive
}

output "reporting_database" {
  description = "The Glue database reporting reads the domain's tables from"
  value       = local.databases[var.parent_domain].reporting
}
