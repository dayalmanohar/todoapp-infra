resource "azurerm_firewall" "fw" {
  for_each = var.firewalls

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  sku_name = "AZFW_VNet"
  sku_tier = lookup(each.value, "sku_tier", "Standard")

  firewall_policy_id = azurerm_firewall_policy.policy[each.key].id

  ip_configuration {
    name                 = "fw-ipconfig"
    subnet_id            = each.value.subnet_id
    public_ip_address_id = each.value.public_ip_id
  }

  tags = each.value.tags
}

resource "azurerm_firewall_policy" "policy" {
  for_each = var.firewalls

  name                = "${each.value.name}-policy"
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
}



resource "azurerm_firewall_policy_rule_collection_group" "app_rules" {
  for_each = var.firewalls

  name               = "app-rule-group"
  firewall_policy_id = azurerm_firewall_policy.policy[each.key].id
  priority           = 100

  application_rule_collection {
    name     = "allow-http-https"
    priority = 100
    action   = "Allow"

    rule {
      name = "allow-web"

      source_addresses = [
        each.value.appgw_subnet_cidr
      ]

      protocols {
        type = "Http"
        port = 80
      }

      protocols {
        type = "Https"
        port = 443
      }

      destination_fqdns = ["*"]
    }
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "network_rules" {
  for_each = var.firewalls

  name               = "network-rule-group"
  firewall_policy_id = azurerm_firewall_policy.policy[each.key].id
  priority           = 200

  network_rule_collection {
    name     = "frontend-to-backend"
    priority = 200
    action   = "Allow"

    rule {
      name                  = "allow-api"
      protocols             = ["TCP"]
      source_addresses      = [each.value.frontend_subnet_cidr]
      destination_addresses = [each.value.backend_subnet_cidr]
      destination_ports     = ["8080"]
    }
  }
}


