#!/bin/bash

set -eu

# validation checks
if [[ $TF_VAR_env != "test" && $TF_VAR_env != sbx-[0-9a-z]* ]]; then
  echo "The value of \$TF_VAR_env must be 'test' or 'sbx-*', but it is '$TF_VAR_env'."
  exit 1
fi

# define fixed environment vars
[[ $TF_VAR_env == "test" ]] && export TF_VAR_subnet_ip="10.3.101.0/24" || export TF_VAR_subnet_ip="10.4.101.0/24"
#[[ -z ${TF_VAR_network_name:-} ]] && export TF_VAR_network_name=sample-vpc-$TF_VAR_env
#[[ -z ${TF_VAR_subnet_name:-} ]] && export TF_VAR_subnet_name=sample-subnet-$TF_VAR_env

# run tests
terraform init -upgrade
terraform validate
terraform plan
if [ -z ${CI:-} ]; then
  terraform fmt
  terraform apply
  terraform destroy
else
  terraform fmt -check
  terraform apply -auto-approve
  terraform destroy -auto-approve
fi
terraform test -filter=variables.tftest.hcl
terraform test -filter=main.tftest.hcl
