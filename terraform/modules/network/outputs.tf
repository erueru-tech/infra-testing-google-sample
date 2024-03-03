# module.vpc #
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

# google_compute_global_address.peering_ip_range #
output "peering_ip_range_name" {
  value = google_compute_global_address.peering_ip_range.name
}

output "peering_ip_range_purpose" {
  value = google_compute_global_address.peering_ip_range.purpose
}

output "peering_ip_range_address_type" {
  value = google_compute_global_address.peering_ip_range.address_type
}

output "peering_ip_range_subnet_mask" {
  value = google_compute_global_address.peering_ip_range.prefix_length
}

# google_service_networking_connection.peering_network_connection #
output "peering_network_connection_vpc_id" {
  value = google_service_networking_connection.peering_network_connection.network
}

output "peering_network_connection_service" {
  value = google_service_networking_connection.peering_network_connection.service
}

output "peering_network_connection_peering_ranges" {
  value = google_service_networking_connection.peering_network_connection.reserved_peering_ranges
}

# google_compute_network_peering_routes_config.peering_routes #
output "peering_routes_name" {
  value = google_compute_network_peering_routes_config.peering_routes.peering
}

output "peering_routes_vpc_name" {
  value = google_compute_network_peering_routes_config.peering_routes.network
}

output "peering_routes_import_custom_routes" {
  value = google_compute_network_peering_routes_config.peering_routes.import_custom_routes
}

output "peering_routes_export_custom_routes" {
  value = google_compute_network_peering_routes_config.peering_routes.export_custom_routes
}
