variable "network_name" {
  type    = string
  default = "sample-vpc"
}

variable "subnet_name" {
  type    = string
  default = "sample-subnet"
}

# cidrhost関数の第二引数に2を指定しているが、これはGCPの仕様で第4オクテットのホスト部の値が0と1のアドレスが予約されているため
# (別に0でも1でもバリデーションの挙動は変わらないものの)
# https://cloud.google.com/vpc/docs/subnets?hl=ja#unusable-ip-addresses-in-every-subnet
variable "subnet_ip" {
  type    = string
  default = null
  validation {
    condition     = can(cidrhost(var.subnet_ip, 2))
    error_message = "The var.subnet_ip value must be given in CIDR notation."
  }
}

# VPCネットワークピアリングに付与されるIPアドレスの範囲(サブネットマスクは24で固定)
variable "peering_network_address" {
  type        = string
  default     = null
  description = "This variable can accept a network address, e.g. '10.3.2.0'."
  validation {
    # 10.[1-4].[1-254].0のフォーマットに従っているかチェック
    condition     = can(regex("^10\\.[1-4]\\.([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-4])\\.0$", var.peering_network_address))
    error_message = "The var.peering_network_address value must be network address."
  }
}

variable "peering_ip_range_name" {
  type    = string
  default = "sample-peering-ip-range"
}
