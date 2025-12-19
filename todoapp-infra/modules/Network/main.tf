resource "azurerm_virtual_network" "vnet" {
  for_each = var.networks

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  address_space       = each.value.address_space
  tags                = each.value.tags
}

locals {
  subnets = flatten([
    for vnet_key, vnet in var.networks : [
      for subnet in vnet.subnets : {
        key       = "${vnet_key}-${subnet.name}"
        vnet_key  = vnet_key
        name      = subnet.name
        prefixes  = subnet.address_prefixes
      }
    ]
  ])
}

resource "azurerm_subnet" "subnet" {
  for_each = {
    for s in local.subnets : s.key => s
  }

  name                 = each.value.name
  resource_group_name  = var.networks[each.value.vnet_key].resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet[each.value.vnet_key].name
  address_prefixes     = each.value.prefixes
}
