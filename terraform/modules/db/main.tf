# デフォルト値で問題なかったため記述していない設定
# - ディスク容量はSSD:10GB
# - メンテナンス時間は火曜日 8:00—9:00(JST)
module "sql_db" {
  source           = "GoogleCloudPlatform/sql-db/google//modules/mysql"
  version          = "19.0.0"
  project_id       = local.project_id
  region           = var.region
  database_version = "MYSQL_8_0_36"
  # MySQLインスタンス内に作成されるデータベースに関する設定
  # テーブルに絵文字が含まれる値を登録できるようにするためにutf8mb4を指定
  db_name      = var.db_name
  db_charset   = "utf8mb4"
  db_collation = "utf8mb4_bin"
  # 高可用性有効化の設定(本番以外では不要)
  availability_type = var.availability_type
  # 短期間で同じ名前のインスタンスを再作成することは出来ない
  # Terraformのテストコード実行ではapply&destroyを繰り返すので、必ず'random_instance_name=true'を設定する必要がある
  # 以下の2つの設定をすることで、nameの値の末尾にランダムな文字列を付与したインスタンス名になる
  name                 = var.db_instance_name
  random_instance_name = var.random_instance_name
  # インスタンスのスペック
  # デフォルトは'db-n1-standard-1'
  tier = var.tier
  # MySQLログイン用ユーザの名前
  user_name = "sample-mysql-user"
  # インスタンスを配置するVPCの設定
  # 'ipv4_enabled=false'はPublic IPを付与しないという意味
  ip_configuration = {
    ipv4_enabled    = false
    private_network = var.vpc_id
  }
  # 毎朝6時ごろにバックアップ開始(設定時間はUTC)
  # 'binary_log_enabled=true'はレプリケーションなどはやらないものの、ドキュメントの例がtrueを設定しているのと、クセでなんとなく設定
  backup_configuration = {
    binary_log_enabled = true
    enabled            = true
    start_time         = "21:00"
  }
  # 実行に2秒以上かかったクエリをslowクエリとしてログに出力する設定
  database_flags = [
    {
      name  = "slow_query_log"
      value = "on"
    },
    {
      name  = "long_query_time"
      value = "2"
    }
  ]
  # 事故によるデータベース削除を防ぐための設定
  # deletion_protection_enabledの値をtrueにすると、Terraform、API、gcloudコマンド、Cloud Consoleといったすべての方法で削除を禁止する
  # 新規開発の最中などはインスタンスごと作り直したいケースも多いため、本番環境ローンチ後に以後絶対に消すことはないと判断した時だけtrueにするべき値
  # 似た設定として、'deletion_protection'があるが、こちらはTerraform経由での削除のみを禁止する
  # なおシステムの移行などで移行後にインスタンスを削除したい場合は、この値をfalseにしてから削除する流れになると思われる
  deletion_protection         = var.deletion_protection
  deletion_protection_enabled = var.deletion_protection
  # 作成に20分以上かかるケースがあり、デフォルトの30mだと不足するケースが発生しそうであるため
  create_timeout = "60m"
  # この設定を明示的に記述しないと、依存先のリソース作成完了前にインスタンスを作成しようとしてエラーになる
  module_depends_on = [google_service_networking_connection.cloudsql_network_connection]
}

# 以下のドキュメントを参考に設定
# https://cloud.google.com/sql/docs/mysql/samples/cloud-sql-mysql-instance-private-ip?hl=ja
# https://cloud.google.com/vpc/docs/configure-private-services-access?hl=ja
#
# ちなみにname/address/prefix_lengthの値の組み合わせは一度決めたら変更してはいけない
# 途中で変更すると、destroy後の再作成で以下のようなエラーが発生する
# https://github.com/hashicorp/terraform-provider-google/issues/3294
# なお以下のコマンドを実行することで解決はできるとのこと
# https://github.com/hashicorp/terraform-provider-google/issues/3294#issuecomment-476715149
resource "google_compute_global_address" "cloudsql_ip_range" {
  name          = "sample-cloudsql-ip-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = var.cloudsql_network_address
  prefix_length = 24
  network       = var.vpc_id
}

# terraform destroyを実行すると以下のエラーが発生してこのリソースを削除できない
# https://github.com/hashicorp/terraform-provider-google/issues/16275
# ワークアラウンドとしてgoogle-betaプロバイダのバージョンを4.x系に戻すか、必ず以下のコマンドを実行してからdestroyを実行する必要がある
# $ gcloud compute networks peerings delete servicenetworking-googleapis-com --network sample-vpc --project プロジェクト名
resource "google_service_networking_connection" "cloudsql_network_connection" {
  network                 = var.vpc_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.cloudsql_ip_range.name]
}

resource "google_compute_network_peering_routes_config" "cloudsql_peering_routes" {
  peering              = google_service_networking_connection.cloudsql_network_connection.peering
  network              = var.vpc_name
  import_custom_routes = true
  export_custom_routes = true
}

# FIXME globals.tfに作成すると複製されるかのような意図しない挙動があるため調査必要
# それまでモジュール毎に定義
resource "random_id" "gen" {
  byte_length = 3
}
