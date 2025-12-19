output "lb_ids" {
  value = {
    for k, lb in azurerm_lb.ilb : k => lb.id
  }
}

output "private_ips" {
  description = "Private IPs of internal load balancers"
  value = {
    for k, lb in azurerm_lb.ilb :
    k => lb.frontend_ip_configuration[0].private_ip_address
  }
}


output "frontend_ilb_private_ip" {
  value = azurerm_lb.ilb["frontend-ilb"].frontend_ip_configuration[0].private_ip_address
}

output "backend_ilb_private_ip" {
  value = azurerm_lb.ilb["backend-ilb"].frontend_ip_configuration[0].private_ip_address
}
