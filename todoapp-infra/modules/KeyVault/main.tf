resource "azurerm_key_vault" "kv" {
  for_each = var.key_vaults

  name                        = each.value.name
  location                    = each.value.location
  resource_group_name         = each.value.resource_group_name
  tenant_id                   = each.value.tenant_id
  sku_name                    = each.value.sku_name

  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  public_network_access_enabled = true

  tags = each.value.tags
}

# -------------------------------
# Access Policies (optional)
# -------------------------------
resource "azurerm_key_vault_access_policy" "policies" {
  for_each = {
    for item in flatten([
      for kv_key, kv in var.key_vaults : [
        for ap in kv.access_policies : {
          key     = "${kv_key}-${ap.object_id}"
          kv_key  = kv_key
          policy  = ap
        }
      ]
    ]) : item.key => item
  }

  key_vault_id = azurerm_key_vault.kv[each.value.kv_key].id

  tenant_id = each.value.policy.tenant_id
  object_id = each.value.policy.object_id

  key_permissions         = each.value.policy.key_permissions
  secret_permissions      = each.value.policy.secret_permissions
  storage_permissions     = each.value.policy.storage_permissions
}
