data "terraform_remote_state" "tier1" {
  backend = "gcs"
  config = {
    bucket  = "${local.project_id}-terraform"
    prefix  = "terraform/tier1-state"
  }
}
