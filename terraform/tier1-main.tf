module "project_services" {
  source     = "terraform-google-modules/project-factory/google//modules/project_services"
  version    = "14.4.0"
  project_id = local.project_id
  activate_apis = [
    "bigquery.googleapis.com",
    "bigquerymigration.googleapis.com",
    "bigquerystorage.googleapis.com",
    "cloudapis.googleapis.com",
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
    "compute.googleapis.com"
  ]
  # destroy発行時に上記APIが全て無効化されないようにする設定
  disable_services_on_destroy = false
}

module "network" {
  source       = "../../../modules/network"
  service      = var.service
  env          = var.env
  network_name = "sample-vpc"
  subnet_name = "sample-subnet"
  subnet_ip    = var.subnet_ip
}
