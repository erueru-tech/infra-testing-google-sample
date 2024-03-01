# MySQLが配置されるVPCの情報
variable "vpc_id" {
  type    = string
  default = null
  # 以下のアサーション書かなくてもnullが評価されたタイミングでエラーにはなるので趣味の問題か
  validation {
    condition     = var.vpc_id != null
    error_message = "The var.vpc_id value is required."
  }
}

variable "vpc_name" {
  type    = string
  default = null
  validation {
    condition     = var.vpc_name != null
    error_message = "The var.vpc_name value is required."
  }
}

# データベース(MySQLのスキーマ)名やインスタンス名およびランダム化などの設定
# dev~prdの実動環境では固定の名前、testおよびsbxではランダマイズするといった切り替えに使う変数
variable "db_name" {
  type = string
  default = "sample-db"
}


variable "db_instance_name" {
  type = string
  default = "sample-instance"
}


variable "random_instance_name" {
  type = bool
  default = true
}

# テストの実行がスペックに依存しない場合はdb-f1-micro、dev~prdの実稼働環境でこのモジュールを利用する場合は要件にあったtierを選択できるように変数化
variable "tier" {
  type     = string
  default  = "db-f1-micro"
  nullable = false
  validation {
    condition     = contains(["db-f1-micro", "db-n1-standard-1"], var.tier)
    error_message = "The var.tier value must be either 'db-f1-micro' or 'db-n1-standard-1', but it is '${var.tier}'."
  }
}

# 本番環境や可用性のテストを行いたい場合以外では、コスト面の理由から高可用性を無効にしたいケースがあるため変数化
# 通常availability_typeは'ZONAL'もしくは'REGIONAL'を設定するが、sql-dbモジュールでは'ZONAL'を指定したい場合、代わりにnullを指定する
variable "availability_type" {
  type    = string
  default = null
  validation {
    condition     = var.availability_type == null || var.availability_type == "REGIONAL"
    error_message = "The var.availability_type value must be either null or 'REGIONAL', but it is '${var.availability_type == null ? "null" : var.availability_type}'."
  }
}

# sql-dbモジュールのデフォルトの削除保護設定が有効となっているために、テストでdestroyできない問題を解決するために変数化
variable "deletion_protection" {
  type    = bool
  default = false
}

# MySQLに付与されるIPアドレスの範囲はcloudsql_network_addressで指定(サブネットマスクは24で固定)
variable "cloudsql_network_address" {
  type        = string
  default     = null
  description = "This variable can accept a network address, e.g. '10.1.1.0'."
  validation {
    # 10.x.x.0のフォーマットに従っているかチェック
    condition     = can(regex("^10\\.([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-4])\\.([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-4])\\.0$", var.cloudsql_network_address))
    error_message = "The var.cloudsql_network_address value must be network address."
  }
}
