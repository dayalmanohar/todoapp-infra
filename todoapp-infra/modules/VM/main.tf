resource "azurerm_network_interface" "nic" {
  for_each = var.vms

  name                = "${each.value.name}-nic"
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  for_each = {
    for k, vm in var.vms :
    k => vm
    if vm.os_type == "windows"
  }

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  size                = each.value.size

  admin_username = each.value.admin_username
  admin_password = each.value.admin_password   # <-- KV secret injected from root module

  network_interface_ids = [
    azurerm_network_interface.nic[each.key].id
  ]

source_image_reference {
  publisher = try(each.value.image.publisher, "Canonical")
  offer     = try(each.value.image.offer, "0001-com-ubuntu-server-jammy")
  sku       = try(each.value.image.sku, "22_04-lts")
  version   = "latest"
}
  os_disk {
    name                 = "${each.value.name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = each.value.os_disk_type
  }

  tags = each.value.tags
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each = {
    for k, vm in var.vms :
    k => vm
    if vm.os_type == "linux"
  }

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  size                = each.value.size

  admin_username = each.value.admin_username
  admin_password = each.value.admin_password   # <-- KV secret injected

  network_interface_ids = [
    azurerm_network_interface.nic[each.key].id
  ]

  source_image_reference {
  publisher = try(each.value.image.publisher, "Canonical")
  offer     = try(each.value.image.offer, "0001-com-ubuntu-server-jammy")
  sku       = try(each.value.image.sku, "22_04-lts")
  version   = "latest"
}

  os_disk {
    name                 = "${each.value.name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = each.value.os_disk_type
  }

  disable_password_authentication = false   # Important since using password

  tags = each.value.tags
}
