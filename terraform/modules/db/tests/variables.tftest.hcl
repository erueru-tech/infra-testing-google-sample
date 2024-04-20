# var.vpc_idは必ず値を指定しなければいけない
run "assert_vpc_id_1" {
  command = plan
  expect_failures = [
    var.vpc_id,
  ]
}

# var.zoneのデフォルト値は'asia-northeast1-a'である
run "assert_zone_1" {
  command = plan
  variables {
    vpc_id = "projects/infra-testing-google-sample-test/global/networks/sample-vpc"
  }
  assert {
    condition     = var.zone == "asia-northeast1-a"
    error_message = "The default var.zone value must be 'asia-northeast1-a'."
  }
}

# var.db_instance_nameのデフォルト値は'sample-instance'である
run "assert_db_instance_name_1" {
  command = plan
  variables {
    vpc_id = "projects/infra-testing-google-sample-test/global/networks/sample-vpc"
  }
  assert {
    condition     = var.db_instance_name == "sample-instance"
    error_message = "The default var.db_instance_name value must be 'sample-instance'."
  }
}

# var.random_instance_nameのデフォルト値はDB関連名のランダム化(=true)である
run "assert_random_instance_name_1" {
  command = plan
  variables {
    vpc_id = "projects/infra-testing-google-sample-test/global/networks/sample-vpc"
  }
  assert {
    condition     = var.random_instance_name
    error_message = "The default var.random_instance_name value must be true."
  }
}

# var.db_nameのデフォルト値は'sample-db'である
run "assert_db_name_1" {
  command = plan
  variables {
    vpc_id = "projects/infra-testing-google-sample-test/global/networks/sample-vpc"
  }
  assert {
    condition     = var.db_name == "sample-db"
    error_message = "The default var.db_name value must be 'sample-db'."
  }
}

# var.tierのデフォルト値は'db-f1-micro'である
run "assert_tier_1" {
  command = plan
  variables {
    vpc_id = "projects/infra-testing-google-sample-test/global/networks/sample-vpc"
  }
  assert {
    condition     = var.tier == "db-f1-micro"
    error_message = "The default var.tier value must be 'db-f1-micro'."
  }
}

# var.tierには'db-n1-standard-1'を入力出来る
run "assert_tier_2" {
  command = plan
  variables {
    vpc_id = "projects/infra-testing-google-sample-test/global/networks/sample-vpc"
    tier   = "db-n1-standard-1"
  }
}

# var.tierには'db-n1-highmem-2'を入力出来ない
# ref. https://cloud.google.com/sql/docs/mysql/instance-settings?hl=ja#machine-type-2ndgen
run "assert_tier_3" {
  command = plan
  variables {
    vpc_id = "projects/infra-testing-google-sample-test/global/networks/sample-vpc"
    tier   = "db-n1-highmem-2"
  }
  expect_failures = [
    var.tier,
  ]
}

# var.availability_typeのデフォルト値は'ZONAL(=null)'である
run "assert_availability_type_1" {
  command = plan
  variables {
    vpc_id = "projects/infra-testing-google-sample-test/global/networks/sample-vpc"
  }
  assert {
    condition     = var.availability_type == null
    error_message = "The default var.availability_type value must be null."
  }
}

# var.availability_typeには'REGIONAL'を入力出来る
run "assert_availability_type_2" {
  command = plan
  variables {
    vpc_id            = "projects/infra-testing-google-sample-test/global/networks/sample-vpc"
    availability_type = "REGIONAL"
  }
}

# var.availability_typeには'ZONAL(=null)'もしくは'REGIONAL'以外を入力出来ない
run "assert_availability_type_3" {
  command = plan
  variables {
    vpc_id            = "projects/infra-testing-google-sample-test/global/networks/sample-vpc"
    availability_type = "GLOBAL"
  }
  expect_failures = [
    var.availability_type,
  ]
}

# var.deletion_protectionのデフォルト値は削除保護無し(=false)である
run "assert_deletion_protection_1" {
  command = plan
  variables {
    vpc_id = "projects/infra-testing-google-sample-test/global/networks/sample-vpc"
  }
  assert {
    condition     = !var.deletion_protection
    error_message = "The default var.deletion_protection value must be false."
  }
}
