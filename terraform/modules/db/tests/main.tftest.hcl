run "apply_db" {
  # Cloud SQLインスタンスの接続エンドポイント名が意図する値であることを確認
  assert {
    condition     = can(regex("^${var.service}-${var.env}:${var.region}:${var.db_instance_name}-[a-z0-9]{8}$", output.mysql_main_connection_name))
    error_message = "The output.mysql_main_connection_name value isn't expected. Please see the above values."
  }
  # Cloud SQLインスタンスが配置されたサブネットのネットワークアドレスが意図する範囲であることを確認
  assert {
    condition     = can(regex("^10.(3|4).2.([2-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-3])$", output.mysql_main_private_ip_address))
    error_message = "The output.mysql_main_private_ip_address value isn't expected. Please see the above value."
  }
  # Cloud SQLインスタンスにPublic IPが割り当てられていないことを確認
  assert {
    condition     = output.mysql_main_public_ip_address == ""
    error_message = "Cloud SQL instance can be accessed from public network."
  }
  # MySQL接続用ユーザのパスワードが32文字であることを確認
  assert {
    condition     = length(nonsensitive(output.mysql_main_user_password)) == 32
    error_message = "The length of the output.mysql_main_user_password must be 32."
  }
}
