run "apply_vpc" {
  # module.vpc #
  # VPCのIDがテスト用のtest-sample-vpcという値を含んで生成されていることを確認(リグレッション目的)
  assert {
    condition     = output.vpc_id == "projects/${var.service}-${var.env}/global/networks/test-sample-vpc"
    error_message = "The output.vpc_id value isn't expected. Please see the above values."
  }
  # VPC名がテスト用のtest-sample-vpcという値で生成されていることを確認
  assert {
    condition     = output.vpc_name == "test-sample-vpc"
    error_message = "The output.vpc_name value isn't expected. Please see the above values."
  }
  # サブネットのIDがテスト用のtest-sample-subnetという値を含んで生成されていることを確認
  assert {
    condition     = length(output.subnets_ids) == 1 && output.subnets_ids[0] == "projects/${var.service}-${var.env}/regions/${var.region}/subnetworks/test-sample-subnet"
    error_message = "The output.subnets_ids value isn't expected. Please see the above values."
  }
  # var.subnet_ipで指定したネットワークアドレスの値がサブネットのIP範囲になっていることを確認
  assert {
    condition     = length(output.subnets_ips) == 1 && output.subnets_ips[0] == var.subnet_ip
    error_message = "The output.subnets_ips value isn't expected. Please see the above values."
  }
  # VPCのsubnets_private_access(Global IPなしでGoogleのAPIに接続するための設定)が有効になっていることを確認
  assert {
    condition     = length(output.subnets_private_access) == 1 && output.subnets_private_access[0]
    error_message = "The subnets_private_access status is expected 'enabled', but it is 'disabled'."
  }

  # google_compute_global_address.peering_ip_range #
  # var.peering_ip_range_nameで指定した名前のIP範囲が生成されていることを確認
  assert {
    condition     = output.peering_ip_range_name == "test-sample-peering-ip-range"
    error_message = "The output.peering_ip_range_name value isn't expected. Please see the above values."
  }
  # IP範囲のpurposeの値が'VPC_PEERING'から変更されていないことを確認
  assert {
    condition     = output.peering_ip_range_purpose == "VPC_PEERING"
    error_message = "The output.peering_ip_range_purpose value isn't expected. Please see the above values."
  }
  # IP範囲のaddress_typeの値が'INTERNAL'から変更されていないことを確認
  assert {
    condition     = output.peering_ip_range_address_type == "INTERNAL"
    error_message = "The output.peering_ip_range_address_type value isn't expected. Please see the above values."
  }
  # IP範囲のサブネットマスクの値が'24'から変更されていないことを確認
  assert {
    condition     = output.peering_ip_range_subnet_mask == 24
    error_message = "The output.peering_ip_range_subnet_mask value isn't expected. Please see the above values."
  }

  # google_service_networking_connection.peering_network_connection #
  # VPCネットワークピアリングのピアリング先VPCネットワークが意図するものであることを確認
  assert {
    condition     = output.peering_network_connection_vpc_id == "projects/${var.service}-${var.env}/global/networks/test-sample-vpc"
    error_message = "The output.peering_network_connection_vpc_id value isn't expected. Please see the above values."
  }
  # VPCネットワークピアリングの接続先サービスが意図するものであることを確認
  assert {
    condition     = output.peering_network_connection_service == "servicenetworking.googleapis.com"
    error_message = "The output.peering_network_connection_service value isn't expected. Please see the above values."
  }
  # VPCネットワークピアリングのピアリング先が意図するものであることを確認
  assert {
    condition     = output.peering_network_connection_peering_ranges == tolist(["test-sample-peering-ip-range"])
    error_message = "The output.peering_network_connection_peering_ranges value isn't expected. Please see the above values."
  }

  # google_compute_network_peering_routes_config.peering_routes #
  # VPCネットワークピアリングルートの設定名が意図するものであることを確認
  assert {
    condition     = output.peering_routes_name == "servicenetworking-googleapis-com"
    error_message = "The output.peering_routes_name value isn't expected. Please see the above values."
  }
  # VPCネットワークピアリングルートに紐づけられているVPC名が意図するものであることを確認
  assert {
    condition     = output.peering_routes_vpc_name == "test-sample-vpc"
    error_message = "The output.peering_routes_vpc_name value isn't expected. Please see the above values."
  }
  # カスタムルートのインポートが有効であることを確認
  assert {
    condition     = output.peering_routes_import_custom_routes
    error_message = "The output.peering_routes_import_custom_routes value isn't expected. Please see the above values."
  }
  # カスタムルートのエクスポートが有効であることを確認
  assert {
    condition     = output.peering_routes_export_custom_routes
    error_message = "The output.peering_routes_export_custom_routes value isn't expected. Please see the above values."
  }
}
