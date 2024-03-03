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
