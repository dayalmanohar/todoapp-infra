output "application_gateway_ids" {
  description = "Application Gateway IDs"
  value = {
    for k, agw in azurerm_application_gateway.agw : k => agw.id
  }
}

output "frontend_public_ips" {
  description = "Frontend public IPs"
  value = {
    for k, agw in azurerm_application_gateway.agw :
    k => agw.frontend_ip_configuration[0].public_ip_address_id
  }
}
