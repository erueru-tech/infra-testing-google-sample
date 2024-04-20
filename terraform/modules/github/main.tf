locals {
  sa_github_display_name = "SA for GitHub Actions"
}

# gh-oidcモジュールを使用
# ref. https://registry.terraform.io/modules/terraform-google-modules/github-actions-runners/google/latest/submodules/gh-oidc
# Workload Identityプールプロバイダは削除から30日以内であれば取り消せる仕様から、同じプール名で連続作成できない点に注意
# ref. https://cloud.google.com/iam/docs/manage-workload-identity-pools-providers?hl=ja#delete-provider
module "gh_oidc" {
  source      = "terraform-google-modules/github-actions-runners/google//modules/gh-oidc"
  version     = "3.1.2"
  project_id  = local.project_id
  pool_id     = var.random_oidc_pool_id ? "${var.oidc_pool_id}-${random_id.gen.hex}" : var.oidc_pool_id
  provider_id = var.oidc_provider_id
  sa_mapping = {
    (google_service_account.github.account_id) = {
      sa_name   = google_service_account.github.name
      attribute = "attribute.repository/${local.github_account_name}/${local.github_repo_name}"
    }
  }
}

# 長さ6文字の16進数文字列が生成される
resource "random_id" "gen" {
  byte_length = 3
}

resource "google_service_account" "github" {
  project      = local.project_id
  account_id   = var.sa_account_id
  display_name = local.sa_github_display_name
  description  = local.sa_github_display_name
}

# Github Actions実行用のサービスアカウントにownerロールを付与するのは危険ではあるが、厳密にロールを管理しようとすると
# インフラ改修のたびにGithub Actions上で行われるリリース(terrsform apply)に必要なロールを追加する作業が必要になってくる
# そしてその作業は、ローカル環境から直接本番やstaging環境に対してapplyを実行することになり、むしろそちらの方が危険であると考えて現状はこのようにしている
resource "google_project_iam_member" "github" {
  project = local.project_id
  member  = "serviceAccount:${google_service_account.github.email}"
  role    = each.value
  for_each = toset([
    "roles/owner"
  ])
}

# CI/CD環境からTerraformのstateをロック、更新するために必要な権限
resource "google_storage_bucket_iam_member" "github" {
  bucket = var.terraform_bucket
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.github.email}"
}
