module "db" {
  source       = "../../../modules/db"
  service      = var.service
  env          = var.env
  vpc_id = data.terraform_remote_state.tier1.outputs.vpc_id
  availability_type = var.availability_type
}
