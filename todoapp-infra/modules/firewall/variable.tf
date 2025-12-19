variable "firewalls" {
  description = "Resolved firewall configuration"
  type = map(object({
    name                = string
    location            = string
    resource_group_name = string

    sku_tier = string

    subnet_id    = string
    public_ip_id = string

    appgw_subnet_cidr    = string
    frontend_subnet_cidr = string
    backend_subnet_cidr  = string

    tags = map(string)
  }))
}
