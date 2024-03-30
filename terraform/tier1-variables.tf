variable "subnet_ip" {
  type    = string
  default = null
  validation {
    condition     = var.subnet_ip != null
    error_message = "The var.subnet_ip value is required."
  }
}

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
