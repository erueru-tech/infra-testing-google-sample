# tflint-ignore-file: terraform_standard_module_structure, terraform_unused_declarations

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.19.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "5.19.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }
  required_version = "1.7.5"
}

provider "google" {
  project = local.project_id
  region  = var.region
}

provider "google-beta" {
  project = local.project_id
  region  = var.region
}

locals {
  github_account_name = "erueru-tech"
  github_repo_name    = "infra-testing-google-sample"
  project_id          = join("-", [var.service, var.env])
  terraform_bucket    = "${local.project_id}-terraform"
}

# (プロジェクト作成後で手遅れの可能性もあるが)サービス名＋ハイフン＋環境名を30文字以内に抑えなければいけないことを考えると、
# 環境名の最大例が'-sbx-xx'と7文字なので、サービス名は23文字以内でなければいけない
variable "service" {
  type    = string
  default = null
  validation {
    condition     = length(var.service) <= 23
    error_message = "The length of the var.service value must be less than or equal to 23."
  }
}

# 以下の定義ならlocalsでリテラルの値を定義したほうがいいが、将来的に許可リージョンを増やすことを想定
variable "region" {
  type    = string
  default = "asia-northeast1"
  validation {
    condition     = var.region == "asia-northeast1"
    error_message = "The var.region value must be 'asia-northeast1', but it is '${var.region}'."
  }
}
