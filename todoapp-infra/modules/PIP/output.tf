output "public_ip_ids" {
  value = {
    for k, v in azurerm_public_ip.pips :
    k => v.id
  }
}

output "public_ip_addresses" {
  value = {
    for k, v in azurerm_public_ip.pips :
    k => v.ip_address
  }
}

output "public_ip_fqdns" {
  value = {
    for k, v in azurerm_public_ip.pips :
    k => v.fqdn
  }
}
