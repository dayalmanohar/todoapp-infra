variable "vms" {
  type = map(object({
    name                = string
    location            = string
    size                = string
    os_type             = string

    admin_username = string
    admin_password = optional(string)

    # NEW (needed for vnet/subnet lookup)
    vnet_key   = string
    subnet_key = string

    resource_group_name = optional(string)

    image = optional(object({
      publisher = string
      offer     = string
      sku       = string
    }), null)

    subnet_id = optional(string)

    os_disk_type = optional(string, "StandardSSD_LRS")
    tags         = optional(map(string), {})
  }))
}
