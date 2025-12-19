output "subnet_ids" {
  value = {
    for vnet_key, vnet in var.networks :
    vnet_key => {
      for s in azurerm_subnet.subnet :
      s.name => s.id
      if s.virtual_network_name == azurerm_virtual_network.vnet[vnet_key].name
    }
  }
}

output "subnet_cidrs" {
  value = {
    for vnet_key, vnet in var.networks :
    vnet_key => {
      for s in azurerm_subnet.subnet :
      s.name => s.address_prefixes[0]
      if s.virtual_network_name == azurerm_virtual_network.vnet[vnet_key].name
    }
  }
}
