#!/bin/bash

set -eu

readonly TEST_TIER2_DIR=$(cd "$(dirname "$0")" && pwd)

# validation checks
if [[ $TF_VAR_env != "test" ]]; then
  echo "The value of \$TF_VAR_env must be 'test', but it is '$TF_VAR_env'."
  exit 1
fi

# run apply command
cd $TEST_TIER2_DIR
terraform init -backend-config="bucket=$TF_VAR_service-$TF_VAR_env-terraform" -upgrade
if [ -z ${CI:-} ]; then
  terraform destroy
else
  terraform destroy -auto-approve
fi

# clean up
readonly VPC_NAME=$(cd ../tier1 && terraform output -raw vpc_name)
gcloud compute networks peerings delete \
  servicenetworking-googleapis-com \
  --network $VPC_NAME \
  --project $TF_VAR_service-$TF_VAR_env
