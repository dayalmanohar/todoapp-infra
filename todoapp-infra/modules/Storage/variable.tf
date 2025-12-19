variable "storage_accounts" {
  type = map(object({
    name                     = string
    resource_group_name      = string
    location                 = string

    account_tier             = string          # Standard/Premium
    account_replication_type = string          # LRS/GRS/RAGRS/ZRS
    account_kind             = optional(string, "StorageV2")
    access_tier              = optional(string, "Hot")

    tags = optional(map(string), {})

    containers = optional(list(object({
      name        = string
      access_type = optional(string, "private")
    })), [])

    file_shares = optional(list(object({
      name  = string
      quota = optional(number, 50)
    })), [])
  }))
}
