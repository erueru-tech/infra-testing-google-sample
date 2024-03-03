#!/bin/bash

set -eu

# validation checks
if [[ $TF_VAR_env != "test" && $TF_VAR_env != sbx-[0-9a-z]* ]]; then
  echo "The value of \$TF_VAR_env must be 'test' or 'sbx-*', but it is '$TF_VAR_env'."
  exit 1
fi

# define fixed environment vars
# main.tftest.hclのvariablesで既に定義している値は定義しない方針
if [[ $TF_VAR_env == "test" ]]; then
  SUBNET_IP="10.3.101.0/24"
  PEERING_NETWORK_ADDRESS="10.3.102.0"
elif [[  $TF_VAR_env == "sbx-e" ]]; then
  SUBNET_IP="10.4.101.0/24"
  PEERING_NETWORK_ADDRESS="10.4.102.0"
fi
echo "SUBNET_IP=$SUBNET_IP"
echo "PEERING_NETWORK_ADDRESS=$PEERING_NETWORK_ADDRESS"

# run tests
terraform init -upgrade
terraform validate
TF_VAR_subnet_ip=$SUBNET_IP \
  TF_VAR_peering_network_address=$PEERING_NETWORK_ADDRESS \
  terraform plan
if [ -z ${CI:-} ]; then
  terraform fmt
else
  terraform fmt -check
fi
terraform test -filter=tests/variables.tftest.hcl
TF_VAR_subnet_ip=$SUBNET_IP \
  TF_VAR_peering_network_address=$PEERING_NETWORK_ADDRESS \
  terraform test -filter=tests/main.tftest.hcl
