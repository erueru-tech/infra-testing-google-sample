# 以下のテストをterraform testコマンドで実行する際、TF_VAR_xxxで正しいservice、envの値を渡す必要がある
# 例: テストを実行する場合、CI専用環境、個人環境問わず以下のコマンドを実行する
# $ cd /path/to/modules/db
# $ terraform init
# $ TF_VAR_service=infra-testing-google-sample \
#   TF_VAR_env=test \
#   terraform test -filter=tests/variables.tftest.hcl
variables {
  vpc_id = "projects/infra-testing-google-sample-test/global/networks/sample-vpc"
  vpc_name = "sample-vpc"
  cloudsql_network_address = "10.3.102.0"
}

# var.db_nameのデフォルト値は'sample-db'である
run "assert_db_name_1" {
  command = plan
  assert {
    condition     = var.db_name == "sample-db"
    error_message = "The default var.db_name value must be 'sample-db'."
  }
}

# var.db_instance_nameのデフォルト値は'sample-instance'である
run "assert_db_instance_name_1" {
  command = plan
  assert {
    condition     = var.db_instance_name == "sample-instance"
    error_message = "The default var.db_instance_name value must be 'sample-instance'."
  }
}

# var.random_instance_nameのデフォルト値はDB関連名のランダム化(='true')である
run "assert_random_instance_name_1" {
  command = plan
  assert {
    condition     = var.random_instance_name
    error_message = "The default var.random_instance_name value must be 'true'."
  }
}
