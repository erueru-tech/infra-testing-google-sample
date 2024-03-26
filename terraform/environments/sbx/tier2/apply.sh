#!/bin/bash

set -eu

readonly SBX_TIER2_DIR=$(cd "$(dirname "$0")" && pwd)

# validation checks
if [[ $TF_VAR_env != sbx-[0-9a-z]* ]]; then
  echo "The value of \$TF_VAR_env must be start with 'sbx-', but it is '$TF_VAR_env'."
  exit 1
fi

# run apply command
cd $SBX_TIER2_DIR
terraform init -backend-config="bucket=$TF_VAR_service-$TF_VAR_env-terraform" -upgrade
if [ -z ${CI:-} ]; then
  terraform apply
else
  terraform apply -auto-approve
fi
