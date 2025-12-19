variable "nics" {
  type = map(object({
    name                = string
    location            = string
    resource_group_name = string

    vnet_key        = string
    subnet_key      = string
    private_ip_type = string
    public_ip_key   = optional(string)
    nsg_key         = optional(string)

    # These are passed from ROOT main.tf
    subnet_id    = optional(string)
    public_ip_id = optional(string)
    nsg_id       = optional(string)

    tags = optional(map(string), {})
  }))
}


