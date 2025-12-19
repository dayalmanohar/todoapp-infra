rgs = {
  rg1 = {
    name = "todo-dev-rg"
  }
}

networks = {
  vnet-dev = {
    name          = "todo-dev-vnet"
    address_space = ["10.0.0.0/16"]

    subnets = [
      { name = "subnet-app", address_prefixes = ["10.0.1.0/24"] },
      { name = "subnet-db", address_prefixes = ["10.0.2.0/24"] },
      { name = "AzureBastionSubnet", address_prefixes = ["10.0.30.0/26"] },
      { name = "AzureFirewallSubnet", address_prefixes = ["10.0.10.0/26"] },
      { name = "AppGatewaySubnet", address_prefixes = ["10.0.20.0/24"] }
    ]
  }
}

nsgs = {
  app-nsg = {
    name       = "app-nsg"
    vnet_key   = "vnet-dev"
    subnet_key = "subnet-app"

    security_rules = [
      {
        name                       = "Allow-SSH"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]
  }
}

pips = {
  bastion-pip = {
    name              = "bastion-pip"
    allocation_method = "Static"
  }

  fw-pip = {
    name              = "fw-pip"
    allocation_method = "Static"
  }

  agw-pip = {
    name              = "agw-pip"
    allocation_method = "Static"
  }
}



loadbalancers = {
  app-lb = {
    name          = "app-lb"
    public_ip_key = "dev-pip"

    frontend_name     = "frontend"
    backend_pool_name = "backend"

    probe = {
      name      = "tcp-probe"
      protocol  = "Tcp"
      port      = 80
      interval  = 5
      threshold = 2
    }

    rules = [
      {
        name          = "http-rule"
        protocol      = "Tcp"
        frontend_port = 80
        backend_port  = 80
      }
    ]
  }
}

# nics = {
#   nic1 = {
#     name            = "todo-dev-vm01-nic"
#     vnet_key        = "vnet-dev"
#     subnet_key      = "subnet-app"
#     private_ip_type = "Dynamic"
#     nsg_key         = "app-nsg"
#   }
# }
nics = {
  frontend-nic = {
    name            = "frontend-nic"
    vnet_key        = "vnet-dev"
    subnet_key      = "subnet-app"
    private_ip_type = "Dynamic"
    nsg_key         = "frontend-nsg"
  }

  backend-nic = {
    name            = "backend-nic"
    vnet_key        = "vnet-dev"
    subnet_key      = "subnet-db"
    private_ip_type = "Dynamic"
    nsg_key         = "backend-nsg"
  }
}

vms = {
  frontend-vm = {
    name           = "frontend-vm"
    size           = "Standard_DS1_v2"
    os_type        = "linux"
    admin_username = "azureadmin"

    vnet_key   = "vnet-dev"
    subnet_key = "subnet-app"
    nic_key    = "frontend-nic"
  }

  backend-vm = {
    name           = "backend-vm"
    size           = "Standard_DS1_v2"
    os_type        = "linux"
    admin_username = "azureadmin"

    vnet_key   = "vnet-dev"
    subnet_key = "subnet-db"
    nic_key    = "backend-nic"
  }
}


firewalls = {
  fw-dev = {
    name     = "fw-dev"
    sku_tier = "Standard"

    vnet_key = "vnet-dev"

    subnet_key    = "AzureFirewallSubnet"
    public_ip_key = "fw-pip"

    appgw_subnet_key    = "AppGatewaySubnet"
    frontend_subnet_key = "subnet-app"
    backend_subnet_key  = "subnet-db"

    tags = {
      env = "dev"
    }
  }
}
