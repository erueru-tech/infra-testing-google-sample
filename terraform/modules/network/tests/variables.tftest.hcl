# var.network_nameのデフォルト値は'sample-vpc'である
run "assert_network_name_1" {
  command = plan
  variables {
    subnet_ip               = "10.3.101.0/24"
    peering_network_address = "10.3.102.0"
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
    subnet_ip               = "10.3.101.0/24"
    peering_network_address = "10.3.102.0"
  }
  assert {
    condition     = var.subnet_name == "sample-subnet"
    error_message = "The default var.subnet_name value must be 'sample-subnet'."
  }
}

# var.subnet_ipは必ず値を指定しなければいけない
run "assert_subnet_ip_1" {
  command = plan
  variables {
    peering_network_address = "10.3.102.0"
  }
  expect_failures = [
    var.subnet_ip,
  ]
}

# var.subnet_ipはCIDR表記の値を渡す必要がある
run "assert_subnet_ip_2" {
  command = plan
  variables {
    subnet_ip               = "10.3.101.2" # error
    peering_network_address = "10.3.102.0"
  }
  expect_failures = [
    var.subnet_ip,
  ]
}

# var.subnet_ipはCIDR範囲を渡す必要がある
run "assert_subnet_ip_3" {
  command = plan
  variables {
    subnet_ip               = "10.3.101.2/32" # error
    peering_network_address = "10.3.102.0"
  }
  expect_failures = [
    var.subnet_ip,
  ]
}


# var.peering_network_addressは必ず値を指定しなければいけない
run "assert_peering_network_address_1" {
  command = plan
  variables {
    subnet_ip = "10.3.101.0/24"
  }
  expect_failures = [
    var.peering_network_address,
  ]
}

# var.peering_network_addressはサブネットマスクが24のネットワークアドレスを指定する必要がある
run "assert_peering_network_address_2" {
  command = plan
  variables {
    peering_network_address = "10.3.102.1" # error
    subnet_ip               = "10.3.101.0/24"
  }
  expect_failures = [
    var.peering_network_address,
  ]
}

# var.peering_network_addressはサブネットマスクを指定する必要がない
run "assert_peering_network_address_3" {
  command = plan
  variables {
    peering_network_address = "10.3.102.0/24" # error
    subnet_ip               = "10.3.101.0/24"
  }
  expect_failures = [
    var.peering_network_address,
  ]
}

# var.peering_network_addressは'10.[1-4].[1-254].0'の範囲で指定する必要がある
run "assert_peering_network_address_4" {
  command = plan
  variables {
    peering_network_address = "10.0.102.0" # error
    subnet_ip               = "10.3.101.0/24"
  }
  expect_failures = [
    var.peering_network_address,
  ]
}

run "assert_peering_network_address_5" {
  command = plan
  variables {
    peering_network_address = "10.5.102.0" # error
    subnet_ip               = "10.3.101.0/24"
  }
  expect_failures = [
    var.peering_network_address,
  ]
}

run "assert_peering_network_address_6" {
  command = plan
  variables {
    peering_network_address = "10.3.0.0" # error
    subnet_ip               = "10.3.101.0/24"
  }
  expect_failures = [
    var.peering_network_address,
  ]
}

run "assert_peering_network_address_7" {
  command = plan
  variables {
    peering_network_address = "10.3.255.0" # error
    subnet_ip               = "10.3.101.0/24"
  }
  expect_failures = [
    var.peering_network_address,
  ]
}

# var.peering_ip_range_nameのデフォルト値は'sample-peering-ip-range'である
# VPCピアリングのIP範囲の名前は絶対に変更してはいけないため、このテストは重要
run "assert_peering_ip_range_name_1" {
  command = plan
  variables {
    subnet_ip               = "10.3.101.0/24"
    peering_network_address = "10.3.102.0"
  }
  assert {
    condition     = var.peering_ip_range_name == "sample-peering-ip-range"
    error_message = "The default var.peering_ip_range_name value must be 'sample-peering-ip-range'."
  }
}
