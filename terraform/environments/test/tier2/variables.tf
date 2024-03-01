variable "env" {
  type    = string
  default = null
  validation {
    condition     = var.env == "test"
    error_message = "The var.env value must be 'test', but it is '${var.env}'."
  }
}
