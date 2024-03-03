module "vpc" {
  source       = "terraform-google-modules/network/google"
  version      = "9.0.0"
  project_id   = local.project_id
  network_name = var.network_name
  subnets = [
    {
      subnet_name           = var.subnet_name
      subnet_ip             = var.subnet_ip
      subnet_region         = var.region
      subnet_private_access = "true"
    }
  ]
}

# 以下のドキュメントを参考に設定
# https://cloud.google.com/sql/docs/mysql/samples/cloud-sql-mysql-instance-private-ip?hl=ja
# https://cloud.google.com/vpc/docs/configure-private-services-access?hl=ja
#
# ちなみにname/address/prefix_lengthの値の組み合わせは一度決めたら変更してはいけない
# 途中で変更すると、destroy後の再作成で以下のようなエラーが発生する
# https://github.com/hashicorp/terraform-provider-google/issues/3294
# なお以下のコマンドを実行することで解決出来るとのこと
# https://github.com/hashicorp/terraform-provider-google/issues/3294#issuecomment-476715149
resource "google_compute_global_address" "peering_ip_range" {
  name          = var.peering_ip_range_name
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = var.peering_network_address
  prefix_length = 24
  network       = module.vpc.network_id
}

# このディレクトリ内でterraform applyしたのちにterraform destroyを実行すると以下のエラーが発生して、このリソースを削除できない
# https://github.com/hashicorp/terraform-provider-google/issues/16275
# google-betaプロバイダのバージョン5.11以前は、ワークアラウンドとしてgoogle-betaプロバイダのバージョンを4.x系に戻すか、
# 以下のコマンドを実行してからdestroyをしなければいけなかった
# $ gcloud compute networks peerings delete servicenetworking-googleapis-com --network sample-vpc --project プロジェクト名
# しかしこの挙動はapplyとdestroyを自動的に実行するterraform testコマンドにおいて、destroyが常に失敗して削除できないリソースが残ってしまう原因になる
# なおバージョン5.12以降は'deletion_policy = "ABANDON"'という設定を記述することで、destroyが成功した後で上記ピアリング削除コマンドを
# 実行するといった順序でクリーンアップ出来るようになった
resource "google_service_networking_connection" "peering_network_connection" {
  network                 = module.vpc.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.peering_ip_range.name]
  deletion_policy         = "ABANDON"
}

resource "google_compute_network_peering_routes_config" "peering_peering_routes" {
  peering              = google_service_networking_connection.peering_network_connection.peering
  network              = module.vpc.network_name
  import_custom_routes = true
  export_custom_routes = true
}
