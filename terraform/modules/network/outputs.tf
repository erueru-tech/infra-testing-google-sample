output "vpc_id" {
  value = module.vpc.network_id
}

# google_compute_network_peering_routes_configリソースで必要
output "vpc_name" {
  value = module.vpc.network_name
}

output "subnets_ids" {
  value = module.vpc.subnets_ids
}

output "subnets_ips" {
  value = module.vpc.subnets_ips
}

output "subnets_private_access" {
  value = module.vpc.subnets_private_access
}
