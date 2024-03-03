#!/bin/bash

set -eu

# validation checks
if [[ $TF_VAR_env != "test" && $TF_VAR_env != sbx-[0-9a-z]* ]]; then
  echo "The value of \$TF_VAR_env must be 'test' or 'sbx-*', but it is '$TF_VAR_env'."
  exit 1
fi

# run apply command
# プロジェクトルートからでもこのシェルを実行出来るようにするための処理
cd $(dirname $0)
terraform init -backend-config="bucket=$TF_VAR_service-$TF_VAR_env-terraform" -upgrade
if [[ -z ${CI:-} ]]; then
  terraform apply
else
  terraform apply -auto-approve
fi
