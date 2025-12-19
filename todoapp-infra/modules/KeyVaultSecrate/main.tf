resource "azurerm_key_vault_secret" "secrets" {
  for_each = var.secrets

  name         = each.value.name
  value        = each.value.value
  key_vault_id = each.value.key_vault_id
  content_type = lookup(each.value, "content_type", null)

  tags = each.value.tags
}
