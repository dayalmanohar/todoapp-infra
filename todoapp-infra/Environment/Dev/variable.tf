variable "rgs" {
  type = map(object({
    name = string
  }))
}

variable "networks" {
  type = map(object({
    name          = string
    address_space = list(string)
    subnets = list(object({
      name             = string
      address_prefixes = list(string)
    }))
  }))
}

variable "nsgs" {
  type = map(object({
    name       = string
    vnet_key   = string
    subnet_key = string

    security_rules = list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    }))
  }))
}

variable "pips" {
  type = map(object({
    name              = string
    allocation_method = string
    sku               = optional(string, "Standard")
  }))
}

variable "loadbalancers" {
  type = map(object({
    name          = string
    sku           = optional(string, "Standard")
    public_ip_key = string

    frontend_name     = string
    backend_pool_name = string

    probe = object({
      name      = string
      protocol  = string
      port      = number
      interval  = number
      threshold = number
    })

    rules = list(object({
      name          = string
      protocol      = string
      frontend_port = number
      backend_port  = number
    }))
  }))
}

variable "nics" {
  type = map(object({
    name            = string
    vnet_key        = string
    subnet_key      = string
    private_ip_type = optional(string, "Dynamic")
    public_ip_key   = optional(string)
    nsg_key         = optional(string)
  }))
}


variable "storage_accounts" {
  type = map(object({
    name                     = string
    account_tier             = string
    account_replication_type = string

    containers = optional(list(object({
      name        = string
      access_type = string
    })), [])
  }))
  default = {}
}

variable "key_vaults" {
  type = map(object({
    name     = string
    sku_name = optional(string, "standard")

    access_policies = list(object({
      object_id          = string
      secret_permissions = list(string)
    }))
  }))
  default = {}
}

variable "secrets" {
  type = map(object({
    name   = string
    value  = string
    kv_key = string
  }))
  default = {}
}

variable "vms" {
  type = map(object({
    name           = string
    size           = string
    os_type        = string
    admin_username = string
    vnet_key       = string
    subnet_key     = string
    nic_key        = string
  }))
}

variable "firewalls" {
  description = "Firewall inputs (keys only, resolved in root main.tf)"
  type = map(object({
    name     = string
    sku_tier = optional(string, "Standard")

    vnet_key            = string
    subnet_key          = string
    public_ip_key       = string
    appgw_subnet_key    = string
    frontend_subnet_key = string
    backend_subnet_key  = string

    tags = map(string)
  }))
}


variable "app_gateways" {
  type = map(object({
    name                = string
    location            = string
    resource_group_name = string

    subnet_id    = string
    public_ip_id = string

    frontend_port = number

    frontend_ilb_ip = string
    backend_ilb_ip  = string

    tags = map(string)
  }))
  default = {}
}


variable "bastions" {
  description = "Azure Bastion configuration"
  type = map(object({
    name                = string
    location            = string
    resource_group_name = string
    subnet_id           = string
    public_ip_id        = string
    tags                = map(string)
  }))
  default = {}
}
