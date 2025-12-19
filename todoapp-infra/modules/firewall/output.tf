output "firewall_private_ips" {
  value = {
    for k, fw in azurerm_firewall.fw :
    k => fw.ip_configuration[0].private_ip_address
  }
}

output "firewall_ids" {
  value = {
    for k, fw in azurerm_firewall.fw :
    k => fw.id
  }
}
