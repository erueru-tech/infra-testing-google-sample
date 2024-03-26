#!/bin/bash

set -eu

# validation checks
if [[ $TF_VAR_env != "test" && $TF_VAR_env != sbx-[0-9a-z]* ]]; then
  echo "The value of \$TF_VAR_env must be 'test' or 'sbx-*', but it is '$TF_VAR_env'."
  exit 1
fi

# define fixed environment vars
[[ -z ${TF_VAR_vpc_name:-} ]] && export TF_VAR_vpc_name="$TF_VAR_env-sample-vpc"
[[ -z ${TF_VAR_vpc_id:-} ]] && export TF_VAR_vpc_id="projects/$TF_VAR_service-$TF_VAR_env/global/networks/$TF_VAR_vpc_name"
[[ -z ${TF_VAR_cloudsql_ip_range_name:-} ]] && export TF_VAR_cloudsql_ip_range_name="$TF_VAR_env-sample-cloudsql-ip-range"
[[ $TF_VAR_env == "test" ]] && export TF_VAR_cloudsql_network_address="10.3.102.0" || export TF_VAR_cloudsql_network_address="10.4.102.0"

# run tests
terraform init -upgrade
terraform validate
terraform plan
if [ -z ${CI:-} ]; then
  terraform fmt
else
  terraform fmt -check
fi
terraform test -filter=tests/variables.tftest.hcl
terraform test -filter=tests/main.tftest.hcl
