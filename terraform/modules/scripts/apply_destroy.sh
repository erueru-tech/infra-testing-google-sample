#!/bin/bash

set -eu

# validation checks
if [[ $TF_VAR_env != "test" && $TF_VAR_env != sbx-[0-9a-z]* ]]; then
  echo "The value of \$TF_VAR_env must be 'test' or 'sbx-*', but it is '$TF_VAR_env'."
  exit 1
fi

if [[ $1 != "apply" && $1 != "destroy" ]]; then
  echo "The argument value must be 'apply' or 'destroy', but it is '$1'."
  exit 1
fi

# run apply command
# プロジェクトルートからでもこのシェルを実行出来るようにするための処理
cd $(dirname $0)
# モジュールの動作確認ではstateをモジュールディレクトリ内で管理するため、-backend-configの指定は不要
terraform init -upgrade
# applyコマンド実行に必要な環境変数を読み込み
source "./_tfvars.sh"
# CI環境でこのスクリプトを使う想定はない
terraform $1
