#!/bin/bash

set -eu

readonly TEST_TIER1_DIR=$(cd "$(dirname "$0")" && pwd)

# validation checks
if [[ $TF_VAR_env != "test" ]]; then
  echo "The value of \$TF_VAR_env must be 'test', but it is '$TF_VAR_env'."
  exit 1
fi

# run apply command
cd $TEST_TIER1_DIR
terraform init -backend-config="bucket=$TF_VAR_service-$TF_VAR_env-terraform" -upgrade
if [ -z ${CI:-} ]; then
  terraform apply
else
  terraform apply -auto-approve
fi
