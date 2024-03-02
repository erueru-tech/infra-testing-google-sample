variable "env" {
  type    = string
  default = null
  validation {
    condition     = var.env == "stg"
    error_message = "The var.env value must be 'stg', but it is '${var.env}'."
  }
}
