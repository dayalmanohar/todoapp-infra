resource "azurerm_network_interface" "nic" {
  for_each = var.nics

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = each.value.private_ip_type
    public_ip_address_id          = each.value.public_ip_id
  }

  tags = each.value.tags
}

resource "azurerm_network_interface_security_group_association" "assoc" {
  for_each = var.nics

  network_interface_id      = azurerm_network_interface.nic[each.key].id
  network_security_group_id = each.value.nsg_id

   # ⭐ STEP 3 — Prevent Azure from rejecting null NSG values
  lifecycle {
    ignore_changes = [
      network_security_group_id
    ]
  }
}
