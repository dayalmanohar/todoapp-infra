output "storage_account_ids" {
  value = {
    for k, v in azurerm_storage_account.storage :
    k => v.id
  }
}

output "storage_account_names" {
  value = {
    for k, v in azurerm_storage_account.storage :
    k => v.name
  }
}
