output "mysql_main_user_password" {
  value     = module.sql_db.generated_user_password
  sensitive = true
}

output "mysql_main_connection_name" {
  value = module.sql_db.instance_connection_name
}

output "mysql_main_private_ip_address" {
  value = module.sql_db.private_ip_address
}

output "mysql_main_public_ip_address" {
  value = module.sql_db.public_ip_address
}
