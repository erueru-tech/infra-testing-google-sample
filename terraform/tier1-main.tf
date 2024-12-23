module "project_services" {
  source     = "terraform-google-modules/project-factory/google//modules/project_services"
  version    = "17.1.0"
  project_id = local.project_id
  activate_apis = [
    "bigquery.googleapis.com",
    "bigquerymigration.googleapis.com",
    "bigquerystorage.googleapis.com",
    "cloudapis.googleapis.com",
    "cloudasset.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudtrace.googleapis.com",
    "datastore.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "servicemanagement.googleapis.com",
    "serviceusage.googleapis.com",
    "sql-component.googleapis.com",
    "storage-api.googleapis.com",
    "storage-component.googleapis.com",
    "storage.googleapis.com",
    "servicenetworking.googleapis.com",
    "compute.googleapis.com",
    "sqladmin.googleapis.com",
    "sts.googleapis.com",
    "aiplatform.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com"
  ]
  # destroy発行時に上記APIが全て無効化されないようにする設定
  disable_services_on_destroy = false
}

module "github" {
  source              = "../../../modules/github"
  service             = var.service
  env                 = var.env
  github_account_name = local.github_account_name
  github_repo_name    = local.github_repo_name
  terraform_bucket    = local.terraform_bucket
}

module "network" {
  source                  = "../../../modules/network"
  service                 = var.service
  env                     = var.env
  subnet_ip               = var.subnet_ip
  peering_network_address = var.peering_network_address
}
