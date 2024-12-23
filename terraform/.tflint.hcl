# ref. https://github.com/terraform-linters/tflint/blob/master/docs/user-guide/config.md
config {
}

# ref. https://github.com/terraform-linters/tflint-ruleset-google
plugin "google" {
  enabled = true
  version = "0.30.0"
  source  = "github.com/terraform-linters/tflint-ruleset-google"
}

# resource名はスネークケース表記にする必要がある
rule "terraform_naming_convention" {
  enabled = true
}

# コメントは#を使う(//は使わない)
rule "terraform_comment_syntax" {
  enabled = true
}

# terraformブロック内にrequired_versionを宣言しなければいけない
# なお、このプロジェクトのフォルダ構成で、このルールを満たすのは不可能なので無効化
rule "terraform_required_version" {
  enabled = false
}
