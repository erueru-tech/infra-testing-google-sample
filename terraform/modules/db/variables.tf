# Cloud SQLインスタンスが配置されるVPCのID
variable "vpc_id" {
  type    = string
  default = null
  # 以下のアサーション書かなくてもnullが評価されたタイミングでエラーにはなるので趣味の問題か
  validation {
    condition     = var.vpc_id != null
    error_message = "The var.vpc_id value is required."
  }
}

# Cloud SQLインスタンスが配置されるVPCの名前
variable "vpc_name" {
  type    = string
  default = null
  validation {
    condition     = var.vpc_name != null
    error_message = "The var.vpc_name value is required."
  }
}

# Cloud SQLインスタンスが配置されるZone
# Terraform Mockでテストコードを実装するためだけに宣言が必要になった変数
variable "zone" {
  type    = string
  default = "asia-northeast1-a"
}

# Cloud SQLインスタンス名
# 下記random_instance_nameをtrueにすることで、サフィックスにランダムな文字列が付与される
variable "db_instance_name" {
  type    = string
  default = "sample-instance"
}

# prod、stgといった実動環境では固定の名前でインスタンスを構築して問題ないのでfalseを設定
# testおよびsbx環境では、テスト時に短期間に同じ名前でCloud SQLインスタンスを再作成できない仕様を回避するためにtrueを設定(インスタンス名がランダマイズされる)
variable "random_instance_name" {
  type    = bool
  default = true
}

# Cloud SQLインスタンス内に構築されるデータベース(MySQLではスキーマ)名
variable "db_name" {
  type    = string
  default = "sample-db"
}

# テストの実行がスペックに依存しない場合はdb-f1-microにして、prod、stgのような実稼働環境でインスタンスを作成する場合は要件にあったtierを選択できるように変数化
variable "tier" {
  type     = string
  default  = "db-f1-micro"
  nullable = false
  validation {
    condition     = contains(["db-f1-micro", "db-n1-standard-1"], var.tier)
    error_message = "The var.tier value must be either 'db-f1-micro' or 'db-n1-standard-1', but it is '${var.tier}'."
  }
}

# prod環境や可用性のテストを行いたい場合以外では、コスト面の理由から高可用性を無効にしたいケースがあるため変数化
# 通常availability_typeは'ZONAL'もしくは'REGIONAL'を設定するが、sql-dbモジュールでは'ZONAL'を指定したい場合、代わりにnullを指定する
variable "availability_type" {
  type    = string
  default = null
  validation {
    condition     = var.availability_type == null || var.availability_type == "REGIONAL"
    error_message = "The var.availability_type value must be either null or 'REGIONAL', but it is '${var.availability_type == null ? "null" : var.availability_type}'."
  }
}

# ブループリントのsql-dbモジュールの削除保護設定のデフォルト値が有効となっているために、テストでdestroyできない問題を解決するために変数化
variable "deletion_protection" {
  type    = bool
  default = false
}

# Cloud SQLインスタンスに付与されるIPアドレスの範囲はcloudsql_network_addressで指定(サブネットマスクは24で固定)
variable "cloudsql_network_address" {
  type        = string
  default     = null
  description = "This variable can accept a network address, e.g. '10.3.1.0'."
  validation {
    # 10.x.x.0のフォーマットに従っているかチェック
    condition     = can(regex("^10\\.([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-4])\\.([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-4])\\.0$", var.cloudsql_network_address))
    error_message = "The var.cloudsql_network_address value must be network address."
  }
}

variable "cloudsql_ip_range_name" {
  type    = string
  default = "sample-cloudsql-ip-range"
}
