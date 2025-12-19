output "key_vault_ids" {
  value = {
    for k, v in azurerm_key_vault.kv :
    k => v.id
  }
}

output "key_vault_uris" {
  value = {
    for k, v in azurerm_key_vault.kv :
    k => v.vault_uri
  }
}
