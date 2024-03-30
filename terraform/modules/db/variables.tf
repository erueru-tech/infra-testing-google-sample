# Cloud SQLインスタンスが配置されるVPCのID
variable "vpc_id" {
  type    = string
  default = null
  validation {
    condition     = var.vpc_id != null
    error_message = "The var.vpc_id value is required."
  }
}

# Cloud SQLインスタンスが配置されるZone
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

# prod環境や可用性のテストを行いたい場合以外では、コスト面の理由から高可用性を無効にしたいため変数化
# 通常availability_typeは'ZONAL'もしくは'REGIONAL'を設定するが、sql-dbブループリントモジュールでは'ZONAL'を指定したい場合、代わりにnullを指定する
variable "availability_type" {
  type    = string
  default = null
  validation {
    condition     = var.availability_type == null || var.availability_type == "REGIONAL"
    error_message = "The var.availability_type value must be either null or 'REGIONAL', but it is '${var.availability_type == null ? "null" : var.availability_type}'."
  }
}

# sql-dbブループリントモジュールの削除保護設定のデフォルト値が有効となっているのが原因で、テスト時にdestroyできない問題を解決するためにデフォルト値を無効(false)に設定
variable "deletion_protection" {
  type    = bool
  default = false
}
