locals {
  # structured and curated are shared by every parent domain, so only these vary
  databases = {
    prisons = {
      raw_archive = "raw_archive"
      reporting   = "prisons"
    }
    probation = {
      raw_archive = "raw_archive_probation"
      reporting   = "probation"
    }
  }
}
