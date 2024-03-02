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

variable "availability_type" {
  type    = string
  default = null
  validation {
    condition     = var.availability_type == null || var.availability_type == "REGIONAL"
    error_message = "The var.availability_type value must be either null or 'REGIONAL', but it is '${var.availability_type == null ? "null" : var.availability_type}'."
  }
}
