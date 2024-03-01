variable "env" {
  type    = string
  default = null
  validation {
    condition     =  startswith(var.env, "sbx-")
    error_message = "The value of var.env must start with 'sbx-', but it is '${var.env}'."
  }
}
