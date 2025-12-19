module "rgs" {
  source = "../../modules/RG"

  rgs = {
    for k, rg in var.rgs : k => {
      name     = rg.name
      location = local.location
      tags     = local.common_tags
    }
  }
}

module "network" {
  source     = "../../Modules/Network"
  depends_on = [module.rgs]

  networks = {
    for k, net in var.networks : k => {
      name                = net.name
      location            = local.location
      resource_group_name = local.rg_name
      address_space       = net.address_space
      subnets             = net.subnets
      tags                = local.common_tags
    }
  }
}



module "pips" {
  source     = "../../Modules/PIP"
  depends_on = [module.rgs]

  pips = {
    for k, pip in var.pips : k => {
      name                = pip.name
      location            = local.location
      resource_group_name = local.rg_name
      allocation_method   = pip.allocation_method
      sku                 = pip.sku
      tags                = local.common_tags
    }
  }
}

module "nics" {
  source     = "../../Modules/NIC"
  depends_on = [module.network, module.nsgs, module.pips]

  nics = {
    for k, nic in var.nics : k => {
      name                = nic.name
      location            = local.location
      resource_group_name = local.rg_name

      # ✅ REQUIRED FIELDS (PASS THROUGH)
      vnet_key        = nic.vnet_key
      subnet_key      = nic.subnet_key
      private_ip_type = nic.private_ip_type

      # ✅ RESOLVED VALUES
      subnet_id = module.network.subnet_ids[nic.vnet_key][nic.subnet_key]
      nsg_id    = module.nsgs.nsg_ids[nic.nsg_key]

      tags = local.common_tags
    }
  }
}

module "vms" {
  source     = "../../Modules/VM"
  depends_on = [module.nics, module.network]

  vms = {
    for k, vm in var.vms : k => {
      name                = vm.name
      location            = local.location
      resource_group_name = local.rg_name
      size                = vm.size
      os_type             = vm.os_type
      admin_username      = vm.admin_username

      # ✅ REQUIRED FIELDS (PASS THROUGH)
      vnet_key   = vm.vnet_key
      subnet_key = vm.subnet_key

      # ✅ RESOLVED VALUES
      subnet_id = module.network.subnet_ids[vm.vnet_key][vm.subnet_key]
      nic_id    = module.nics.nic_ids[vm.nic_key]

      tags = local.common_tags
    }
  }
}

module "internal_lbs" {
  source = "../../modules/internal_load_balancer"
  depends_on = [
    module.network,
    module.firewalls
  ]

  loadbalancers = {
    frontend-ilb = {
      name                = "frontend-ilb"
      location            = local.location
      resource_group_name = local.rg_name

      subnet_id         = module.network.subnet_ids["vnet-dev"]["subnet-app"]
      frontend_ip_name  = "fe-ip"
      backend_pool_name = "fe-backend-pool"

      probe = {
        name     = "http-probe"
        protocol = "Tcp"
        port     = 80
      }

      rules = [
        {
          name          = "http-rule"
          protocol      = "Tcp"
          frontend_port = 80
          backend_port  = 80
        }
      ]

      tags = local.common_tags
    }

    backend-ilb = {
      name                = "backend-ilb"
      location            = local.location
      resource_group_name = local.rg_name

      subnet_id         = module.network.subnet_ids["vnet-dev"]["subnet-db"]
      frontend_ip_name  = "be-ip"
      backend_pool_name = "be-backend-pool"

      probe = {
        name     = "api-probe"
        protocol = "Tcp"
        port     = 8080
      }

      rules = [
        {
          name          = "api-rule"
          protocol      = "Tcp"
          frontend_port = 8080
          backend_port  = 8080
        }
      ]

      tags = local.common_tags
    }
  }
}

module "nsgs" {
  source     = "../../modules/nsg"
  depends_on = [module.network, module.firewalls]

  nsgs = {
    frontend-nsg = {
      name                = "frontend-nsg"
      location            = local.location
      resource_group_name = local.rg_name
      subnet_id           = module.network.subnet_ids["vnet-dev"]["subnet-app"]

      security_rules = [
        # Allow HTTP/HTTPS only from Firewall
        {
          name                   = "Allow-From-Firewall-80"
          priority               = 100
          direction              = "Inbound"
          access                 = "Allow"
          protocol               = "Tcp"
          source_port_range      = "*"
          destination_port_range = "80"
          # source_address_prefix      = module.firewalls.firewall_private_ips["fw1"]
          source_address_prefix = module.firewalls.firewall_private_ips["fw-dev"]

          destination_address_prefix = "*"
        },
        {
          name                   = "Allow-From-Firewall-443"
          priority               = 110
          direction              = "Inbound"
          access                 = "Allow"
          protocol               = "Tcp"
          source_port_range      = "*"
          destination_port_range = "443"
          #source_address_prefix      = module.firewalls.firewall_private_ips["fw1"]
          source_address_prefix = module.firewalls.firewall_private_ips["fw-dev"]

          destination_address_prefix = "*"
        }
      ]

      tags = local.common_tags
    }

    backend-nsg = {
      name                = "backend-nsg"
      location            = local.location
      resource_group_name = local.rg_name
      subnet_id           = module.network.subnet_ids["vnet-dev"]["subnet-db"]

      security_rules = [
        # Allow app traffic only from Frontend subnet
        {
          name                       = "Allow-From-Frontend"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "8080"
          source_address_prefix      = "10.0.1.0/24" # Frontend subnet CIDR
          destination_address_prefix = "*"
        }
      ]

      tags = local.common_tags
    }
  }
}

############################################
# Azure Bastion (Developer Access)
############################################
module "bastion" {
  source = "../../modules/bastion"
  depends_on = [
    module.network,
    module.pips
  ]

  bastions = {
    dev-bastion = {
      name                = "dev-bastion"
      location            = local.location
      resource_group_name = local.rg_name

      subnet_id    = module.network.subnet_ids["vnet-dev"]["AzureBastionSubnet"]
      public_ip_id = module.pips.public_ip_ids["bastion-pip"]

      tags = local.common_tags
    }
  }
}

module "app_gateway" {
  source = "../../modules/app_gateway"
  depends_on = [
    module.firewalls,
    module.internal_lbs,
    module.pips,
    module.network
  ]

  app_gateways = {
    dev-agw = {
      name                = "dev-app-gateway"
      location            = local.location
      resource_group_name = local.rg_name

      subnet_id    = module.network.subnet_ids["vnet-dev"]["AppGatewaySubnet"]
      public_ip_id = module.pips.public_ip_ids["agw-pip"]

      frontend_port = 80

      frontend_ilb_ip = module.internal_lbs.private_ips["frontend-ilb"]
      backend_ilb_ip  = module.internal_lbs.private_ips["backend-ilb"]

      tags = local.common_tags
    }
  }
}


# module "firewalls" {
#   source     = "../../modules/firewall"
#   depends_on = [module.network, module.pips]

#   firewalls = {
#     fw-dev = {
#       name                = "fw-dev"
#       location            = local.location
#       resource_group_name = local.rg_name

#       subnet_id    = module.network.subnet_ids["vnet-dev"]["AzureFirewallSubnet"]
#       public_ip_id = module.pips.public_ip_ids["fw-pip"]

#       policy_name = "fw-policy-dev"

#       appgw_subnet_cidr    = "10.0.20.0/24"
#       frontend_subnet_cidr = "10.0.1.0/24"
#       backend_subnet_cidr  = "10.0.2.0/24"

#       tags = local.common_tags
#     }
#   }
# }

module "firewalls" {
  source     = "../../modules/firewall"
  depends_on = [module.network, module.pips]

  firewalls = {
    for k, fw in var.firewalls : k => merge(
      fw,
      {
        location            = local.location
        resource_group_name = local.rg_name

        subnet_id    = module.network.subnet_ids[fw.vnet_key][fw.subnet_key]
        public_ip_id = module.pips.public_ip_ids[fw.public_ip_key]

        appgw_subnet_cidr    = module.network.subnet_cidrs[fw.vnet_key][fw.appgw_subnet_key]
        frontend_subnet_cidr = module.network.subnet_cidrs[fw.vnet_key][fw.frontend_subnet_key]
        backend_subnet_cidr  = module.network.subnet_cidrs[fw.vnet_key][fw.backend_subnet_key]
      }
    )
  }
}
