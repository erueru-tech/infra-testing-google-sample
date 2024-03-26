# tflint-ignore-file: terraform_standard_module_structure

variable "env" {
  type    = string
  default = null
  validation {
    condition     = contains(["prod", "stg", "test"], var.env) || startswith(var.env, "sbx-")
    error_message = "The value of var.env must be 'prod', 'stg', 'test' or start with 'sbx-', but it is '${var.env}'."
  }
}
