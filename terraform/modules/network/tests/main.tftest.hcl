# 以下のテストをterraform testコマンドで実行する際、TF_VAR_xxxで正しいservice、env、subnet_ipの値を渡す必要がある
# 例: erueru-techの個人環境でテストを実行する場合(subnet_ipの値を実行環境に合わせたCIDRにする)
# $ cd /path/to/modules/network
# $ terraform init
# $ TF_VAR_service=infra-testing-google-sample \
#   TF_VAR_env=sbx-e \
#   TF_VAR_subnet_ip=10.4.101.0/24 \
#   terraform test -filter=tests/main.tftest.hcl

# variables.tftest.hclには以下の設定は反映されない様
variables {
  network_name = "test-sample-vpc"
  subnet_name = "test-sample-subnet"
}

run "apply_vpc" {
  # var.network_nameで指定したVPC名を元にVPCのIDが生成されていることを確認
  assert {
    condition     = output.vpc_id  == "projects/${var.service}-${var.env}/global/networks/${var.network_name}"
    error_message = "The output.vpc_id value isn't expected. Please see the above values."
  }
  # 以下のアサーションは上記アサーションと実質同じで、${var.network_name}がtest-sample-vpcというリテラル文字列に置き換わっているだけとなっている
  # 違いとしては、前回apply時点と異なる変数の値を使用してはいけないという意味になる
  # より確実にVPCのIDのリグレッションテストを行いたい場合はconditionにVPC IDをリテラルで記述する
  # またserviceやenv、CIDRといった環境に依存する値はリテラルでテスト条件を記述できない点を考慮する必要がある
  #
  # しかしテストコードの実行は、applyとdestroyが常に行われるため、前回apply時点という状態は基本的に存在しないはずなのでそこまで考えなくてもいいかもしれない
  # ただし一部リソースを残したままにするe2eテストなどでは、このような考慮が必要になる可能性がある
  assert {
    condition     = output.vpc_id  == "projects/${var.service}-${var.env}/global/networks/test-sample-vpc"
    error_message = "The output.vpc_id value isn't expected. Please see the above values."
  }
  # var.network_nameで指定した名前でVPCが作成されていることを確認
  assert {
    condition     = output.vpc_name  == "test-sample-vpc"
    error_message = "The output.vpc_name value isn't expected. Please see the above values."
  }
  # var.subnet_nameで指定したサブネット名を元にサブネットのIDが生成されていることを確認
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
}
