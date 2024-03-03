variable "availability_type" {
  type    = string
  default = null
  validation {
    condition     = var.availability_type == null || var.availability_type == "REGIONAL"
    error_message = "The var.availability_type value must be either null or 'REGIONAL', but it is '${var.availability_type == null ? "null" : var.availability_type}'."
  }
}
