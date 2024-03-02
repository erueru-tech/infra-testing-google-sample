variable "network_name" {
  type    = string
  default = null
}

variable "subnet_name" {
  type    = string
  default = null
}

variable "subnet_ip" {
  type    = string
  default = null
  validation {
    condition     = var.subnet_ip != null
    error_message = "The var.subnet_ip value is required."
  }
}

variable "suffix_length" {
  type    = number
  default = 2
  validation {
    condition     = var.suffix_length >= 2 && var.suffix_length <= 5
    error_message = "The var.suffix length must be between 2 and 5, but it is '${var.suffix_length}'."
  }
}
