locals {
  network_name = var.network_name == null ? "sample-vpc-${random_id.gen.hex}" : var.network_name
  subnet_name = var.subnet_name == null ? "sample-subnet-${random_id.gen.hex}" : var.subnet_name
}

module "vpc" {
  source       = "terraform-google-modules/network/google"
  version      = "9.0.0"
  project_id   = local.project_id
  network_name = local.network_name
  subnets = [
    {
      subnet_name            = local.subnet_name
      subnet_ip              = var.subnet_ip
      subnet_region          = var.region
      subnets_private_access = "true"
    }
  ]
}

resource "random_id" "gen" {
  byte_length = var.suffix_length
}
