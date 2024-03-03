module "db" {
  source       = "../../../modules/db"
  service      = var.service
  env          = var.env
  vpc_id = data.terraform_remote_state.tier1.outputs.vpc_id
  vpc_name = data.terraform_remote_state.tier1.outputs.vpc_name
  availability_type = var.availability_type
}
