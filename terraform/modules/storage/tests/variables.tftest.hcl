# var.sample_bucket_nameのデフォルト値は'erueru-tech-sample-bucket'である
run "assert_sample_bucket_name_1" {
  command = plan
  assert {
    condition     = var.sample_bucket_name == "erueru-tech-sample-bucket"
    error_message = "The default var.sample_bucket_name value must be 'erueru-tech-sample-bucket'."
  }
}
