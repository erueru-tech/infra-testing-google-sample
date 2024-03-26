# 以下のテストをterraform testコマンドで実行する際、TF_VAR_xxxで正しいservice、envの値を渡す必要がある
# 例: テストを実行する場合、CI専用環境、個人環境問わず以下のコマンドを実行する
# $ cd /path/to/modules/network
# $ terraform init
# $ TF_VAR_service=infra-testing-google-sample \
#   TF_VAR_env=test \
#   terraform test -filter=tests/variables.tftest.hcl

# var.network_nameのデフォルト値は'sample-vpc'である
run "assert_network_name_1" {
  command = plan
  variables {
    subnet_ip = "10.3.101.0/24"
  }
  assert {
    condition     = var.network_name == "sample-vpc"
    error_message = "The default var.network_name value must be 'sample-vpc'."
  }
}

# var.subnet_nameのデフォルト値は'sample-subnet'である
run "assert_subnet_name_1" {
  command = plan
  variables {
    subnet_ip = "10.3.101.0/24"
  }
  assert {
    condition     = var.subnet_name == "sample-subnet"
    error_message = "The default var.subnet_name value must be 'sample-subnet'."
  }
}

# var.subnet_ipは必ず値を指定しなければいけない
run "assert_subnet_ip_1" {
  command = plan
  expect_failures = [
    var.subnet_ip,
  ]
}

# var.subnet_ipはCIDR表記の値を渡す必要がある
run "assert_subnet_ip_2" {
  command = plan
  variables {
    subnet_ip = "10.3.101.2"
  }
  expect_failures = [
    var.subnet_ip,
  ]
}

# var.subnet_ipはCIDR範囲を渡す必要がある
run "assert_subnet_ip_3" {
  command = plan
  variables {
    subnet_ip = "10.3.101.2/32"
  }
  expect_failures = [
    var.subnet_ip,
  ]
}
