resource "azurerm_storage_account" "storage" {
  for_each = var.storage_accounts

  name                     = each.value.name
  resource_group_name      = each.value.resource_group_name
  location                 = each.value.location
  account_tier             = each.value.account_tier
  account_replication_type = each.value.account_replication_type
  account_kind             = each.value.account_kind
  access_tier              = each.value.access_tier

  min_tls_version = "TLS1_2"   # this is still valid



  tags = each.value.tags
}



# Storage Containers (optional)

resource "azurerm_storage_container" "containers" {
  for_each = {
    for item in flatten([
      for sa_key, sa in var.storage_accounts : [
        for container in sa.containers : {
          key       = "${sa_key}-${container.name}"
          sa_key    = sa_key
          container = container
        }
      ]
    ]) : item.key => item
  }

  name                  = each.value.container.name
  storage_account_id  = azurerm_storage_account.storage[each.value.sa_key].id
  container_access_type = each.value.container.access_type
}


# --------------------------
# File Shares (optional)
# --------------------------
resource "azurerm_storage_share" "file_shares" {
  for_each = {
    for item in flatten([
      for sa_key, sa in var.storage_accounts : [
        for file_share in sa.file_shares : {
          key        = "${sa_key}-${file_share.name}"
          sa_key     = sa_key
          file_share = file_share
        }
      ]
    ]) : item.key => item
  }

  name                 = each.value.file_share.name
  storage_account_id = azurerm_storage_account.storage[each.value.sa_key].id
  quota                = each.value.file_share.quota
}
