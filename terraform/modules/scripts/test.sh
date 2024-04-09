#!/bin/bash

set -eu

# validation checks
if [[ $TF_VAR_env != "test" && $TF_VAR_env != sbx-[0-9a-z]* ]]; then
  echo "The value of \$TF_VAR_env must be 'test' or 'sbx-*', but it is '$TF_VAR_env'."
  exit 1
fi

# run tests
# プロジェクトルートからでもこのシェルを実行出来るようにするための処理
cd $(dirname $0)
# モジュールの動作確認ではstateをモジュールディレクトリ内で管理するため、-backend-configの指定は不要
terraform init -upgrade
terraform validate
if [[ -z ${CI:-} ]]; then
  terraform fmt
else
  terraform fmt -check
fi
terraform test -filter=tests/variables.tftest.hcl
# planおよびtestコマンド実行に必要な環境変数を読み込み
source "./_tfvars.sh"
terraform plan
# FIXME
#terraform test -filter=tests/main.tftest.hcl
