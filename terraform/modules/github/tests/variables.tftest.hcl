# var.oidc_pool_idのデフォルト値は'sample-pool'である
run "assert_oidc_pool_id_1" {
  command = plan
  variables {
    terraform_bucket = "test-infra-testing-google-sample-test-terraform"
  }
  assert {
    condition     = var.oidc_pool_id == "sample-pool"
    error_message = "The default var.oidc_pool_id value must be 'sample-pool'."
  }
}

# var.random_oidc_pool_idのデフォルト値はWorkload IdentityプールのIDをランダマイズしない(=false)である
run "assert_random_oidc_pool_id_1" {
  command = plan
  variables {
    terraform_bucket = "test-infra-testing-google-sample-test-terraform"
  }
  assert {
    condition     = !var.random_oidc_pool_id
    error_message = "The default var.random_oidc_pool_id value must be false."
  }
}

# var.oidc_provider_idのデフォルト値は'sample-gh-provider'である
run "assert_oidc_provider_id_1" {
  command = plan
  variables {
    terraform_bucket = "test-infra-testing-google-sample-test-terraform"
  }
  assert {
    condition     = var.oidc_provider_id == "sample-gh-provider"
    error_message = "The default var.oidc_provider_id value must be 'sample-gh-provider'."
  }
}

# var.sa_account_idのデフォルト値は'github'である
run "assert_sa_account_id_1" {
  command = plan
  variables {
    terraform_bucket = "test-infra-testing-google-sample-test-terraform"
  }
  assert {
    condition     = var.sa_account_id == "github"
    error_message = "The default var.sa_account_id value must be 'github'."
  }
}

# var.sa_account_idで指定するサービスアカウント名は5文字以下を入力出来ない
run "assert_sa_account_id_2" {
  command = plan
  variables {
    terraform_bucket = "test-infra-testing-google-sample-test-terraform"
    sa_account_id    = "abcde"
  }
  expect_failures = [
    var.sa_account_id,
  ]
}

# var.sa_account_idで指定するサービスアカウント名は31文字以上を入力出来ない
run "assert_sa_account_id_3" {
  command = plan
  variables {
    terraform_bucket = "test-infra-testing-google-sample-test-terraform"
    sa_account_id    = "abcde12345abcde12345abcde12345a"
  }
  expect_failures = [
    var.sa_account_id,
  ]
}

# var.terraform_bucketは必ず値を指定しなければいけない
run "assert_terraform_bucket_1" {
  command = plan
  expect_failures = [
    var.terraform_bucket,
  ]
}

# var.terraform_bucketで渡すバケット名にgs://を含めるとエラーが発生する
run "assert_terraform_bucket_2" {
  command = plan
  variables {
    terraform_bucket = "gs://test-infra-testing-google-sample-test-terraform"
  }
  expect_failures = [
    var.terraform_bucket,
  ]
}
