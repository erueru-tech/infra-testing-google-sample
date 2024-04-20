run "apply_storage" {
  # module.storage #
  # バケット名がtest-erueru-tech-sample-bucketであることを確認
  assert {
    condition     = output.sample_bucket_name == "test-erueru-tech-sample-bucket"
    error_message = "The output.sample_bucket_name value isn't expected. Please see the above values."
  }
}
