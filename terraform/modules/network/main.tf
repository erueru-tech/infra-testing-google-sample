module "vpc" {
  source       = "terraform-google-modules/network/google"
  version      = "9.0.0"
  project_id   = local.project_id
  network_name = var.network_name
  subnets = [
    {
      subnet_name            = var.subnet_name
      subnet_ip              = var.subnet_ip
      subnet_region          = var.region
      subnet_private_access = "true"
    }
  ]
}
