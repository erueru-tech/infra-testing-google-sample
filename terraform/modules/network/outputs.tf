output "vpc_id" {
  value = module.vpc.network_id
}

# google_compute_network_peering_routes_configリソースで必要
output "vpc_name" {
  value = module.vpc.network_name
}
