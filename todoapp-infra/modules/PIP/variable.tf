variable "pips" {
  type = map(object({
    name                = string
    location            = string
    resource_group_name = string
    allocation_method   = string           # Static or Dynamic
    sku                 = optional(string, "Standard")

    domain_name_label   = optional(string, null)
    tags                = optional(map(string), {})
  }))
}
