export TF_VAR_network_name="test-sample-vpc"
export TF_VAR_subnet_name="test-sample-subnet"
export TF_VAR_peering_ip_range_name="test-sample-peering-ip-range"
if [[ $TF_VAR_env == "test" ]]; then
  export TF_VAR_subnet_ip="10.3.101.0/24"
  export TF_VAR_peering_network_address="10.3.102.0"
elif [[  $TF_VAR_env == "sbx-e" ]]; then
  export TF_VAR_subnet_ip="10.4.101.0/24"
  export TF_VAR_peering_network_address="10.4.102.0"
fi
