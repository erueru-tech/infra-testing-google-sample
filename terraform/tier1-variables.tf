variable "subnet_ip" {
  type    = string
  default = null
  validation {
    condition     = var.subnet_ip != null
    error_message = "The var.subnet_ip value is required."
  }
}
