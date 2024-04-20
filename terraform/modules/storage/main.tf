resource "google_storage_bucket" "sample" {
  name          = var.sample_bucket_name
  location      = "ASIA"
  storage_class = "MULTI_REGIONAL"
  versioning {
    enabled = true
  }
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
}
