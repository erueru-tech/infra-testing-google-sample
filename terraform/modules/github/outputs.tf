# module.gh_oidc #
output "oidc_pool_name" {
  value = module.gh_oidc.pool_name
}

output "oidc_provider_name" {
  value = module.gh_oidc.provider_name
}

# random_id.gen #
output "random_id_string" {
  value = random_id.gen.hex
}

# google_service_account.github #
output "sa_github_account_id" {
  value = google_service_account.github.account_id
}

output "sa_github_name" {
  value = google_service_account.github.name
}

output "sa_github_email" {
  value = google_service_account.github.email
}
