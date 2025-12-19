output "secret_ids" {
  value = {
    for k, v in azurerm_key_vault_secret.secrets :
    k => v.id
  }
}

output "secret_values" {
  value = {
    for k, v in azurerm_key_vault_secret.secrets :
    k => v.value
  }
  sensitive = true
}

output "secret_names" {
  value = {
    for k, v in azurerm_key_vault_secret.secrets :
    k => v.name
  }
}
