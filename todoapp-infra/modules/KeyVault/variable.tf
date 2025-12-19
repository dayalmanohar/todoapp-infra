variable "key_vaults" {
  type = map(object({
    name                = string
    location            = string
    resource_group_name = string
    tenant_id           = string
    sku_name            = optional(string, "standard")
    tags                = optional(map(string), {})

    access_policies = optional(list(object({
      tenant_id           = string
      object_id           = string
      key_permissions     = optional(list(string), [])
      secret_permissions  = optional(list(string), [])
      storage_permissions = optional(list(string), [])
    })), [])
  }))
}
