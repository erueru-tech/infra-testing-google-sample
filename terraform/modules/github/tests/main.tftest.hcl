run "apply_github" {
  # module.gh_oidc #
  # Workload Identityプールの名前が意図する値であることを確認
  assert {
    condition     = can(regex("^projects/[0-9]{12}/locations/global/workloadIdentityPools/test-sample-pool-[a-f0-9]{6}$", output.oidc_pool_name))
    error_message = "The output.oidc_pool_name value isn't expected. Please see the above values."
  }
  # Workload Identityプールプロバイダの名前が意図する値であることを確認
  assert {
    condition     = can(regex("^${output.oidc_pool_name}/providers/test-sample-gh-provider$", output.oidc_provider_name))
    error_message = "The output.oidc_provider_name value isn't expected. Please see the above values."
  }

  # random_id.gen #
  # 生成されるサフィックス用文字列の文字数は3ではなく6
  assert {
    condition     = length(output.random_id_string) == 6
    error_message = "The length of the output.random_id_string value must be equal to 6."
  }

  # google_service_account.github #
  # Github Actions用サービスアカウントのIDが意図する値であることを確認
  assert {
    condition     = output.sa_github_account_id == "test-github"
    error_message = "The output.sa_github_account_id value isn't expected. Please see the above values."
  }
  # Github Actions用サービスアカウント名が意図する値であることを確認
  assert {
    condition     = output.sa_github_name == "projects/${local.project_id}/serviceAccounts/test-github@${local.project_id}.iam.gserviceaccount.com"
    error_message = "The output.sa_github_name value isn't expected. Please see the above values."
  }
  # Github Actions用サービスアカウントのメールアドレスが意図する値であることを確認
  assert {
    condition     = output.sa_github_email == "test-github@${local.project_id}.iam.gserviceaccount.com"
    error_message = "The output.sa_github_email value isn't expected. Please see the above values."
  }
}
