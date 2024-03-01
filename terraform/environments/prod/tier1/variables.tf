variable "env" {
  type    = string
  default = null
  validation {
    condition     = var.env == "prod"
    error_message = "The var.env value must be 'prod', but it is '${var.env}'."
  }
}
