# Github Actions用Workload IdentityプールのID
variable "oidc_pool_id" {
  type    = string
  default = "sample-pool"
}

# trueを設定するとWorkload IdentityプールのIDのサフィックスにランダムな文字列を付与する設定
variable "random_oidc_pool_id" {
  type    = bool
  default = false
}

# Github Actions用Workload IdentityプールプロバイダのID
variable "oidc_provider_id" {
  type    = string
  default = "sample-gh-provider"
}


# Github Actionsのジョブ実行用サービスアカウント名
variable "sa_account_id" {
  type    = string
  default = "github"
  # サービスアカウント名の文字列長は6～30文字でなければいけない
  # ref. https://cloud.google.com/iam/docs/service-accounts-create?hl=ja#creating
  validation {
    condition     = length(var.sa_account_id) >= 6 && length(var.sa_account_id) <= 30
    error_message = "The length of the var.sa_account_id value must be between 6 and 30."
  }
}

# Terraformのstate管理バケット名(setup_gcp_project.shで作成しているテスト用のfakeバケット含む)
variable "terraform_bucket" {
  type    = string
  default = null
  validation {
    condition     = var.terraform_bucket != null
    error_message = "The var.terraform_bucket value is required."
  }
  # バケット名を指定するだけで良く、gs://は不要
  validation {
    condition     = !can(regex("^gs:\\/\\/", var.terraform_bucket))
    error_message = "The var.terraform_bucket value doesn't need to specify 'gs://' prefix."
  }
}
