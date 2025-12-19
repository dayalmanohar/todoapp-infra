output "vm_ids" {
  value = {
    for k, v in azurerm_windows_virtual_machine.vm : k => v.id
  }
}

output "nic_ids" {
  value = {
    for k, v in azurerm_network_interface.nic : k => v.id
  }
}

