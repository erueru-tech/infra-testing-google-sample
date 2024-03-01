# ref. https://github.com/terraform-linters/tflint/blob/master/docs/user-guide/config.md
config {
}

# ref. https://github.com/terraform-linters/tflint-ruleset-google
plugin "google" {
  enabled = true
  version = "0.27.1"
  source  = "github.com/terraform-linters/tflint-ruleset-google"
}

# ref. https://github.com/terraform-linters/tflint-ruleset-opa
# Policy files are placed under ~/.tflint.d/policies or ./.tflint.d/policies.
plugin "opa" {
  enabled = true
  version = "0.6.0"
  source  = "github.com/terraform-linters/tflint-ruleset-opa"
}

# resource名はスネークケース表記にする必要がある
rule "terraform_naming_convention" {
  enabled = true
}

# コメントは#を使う(//は使わない)
rule "terraform_comment_syntax" {
  enabled = true
}

# このプロジェクトのフォルダ構成でこのルールを満たすのは不可能なので無効化
rule "terraform_required_version" {
  enabled = false
}
