# tflint-ignore-file: terraform_standard_module_structure

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
  required_version = "1.7.4"
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
  project_id = join("-", [var.service, var.env])
}

# TODO GCPのプロジェクト名は30文字以内であることを考慮したバリデーションを記述
variable "service" {
  type    = string
  default = null
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
