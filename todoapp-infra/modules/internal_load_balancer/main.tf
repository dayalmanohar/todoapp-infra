resource "azurerm_lb" "ilb" {
  for_each = var.loadbalancers

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = each.value.frontend_ip_name
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = each.value.frontend_private_ip != null ? "Static" : "Dynamic"
    private_ip_address            = each.value.frontend_private_ip
  }

  tags = each.value.tags
}

resource "azurerm_lb_backend_address_pool" "backend" {
  for_each = var.loadbalancers

  name            = each.value.backend_pool_name
  loadbalancer_id = azurerm_lb.ilb[each.key].id
}

resource "azurerm_lb_probe" "probe" {
  for_each = var.loadbalancers

  name            = each.value.probe.name
  protocol        = each.value.probe.protocol
  port            = each.value.probe.port
  loadbalancer_id = azurerm_lb.ilb[each.key].id
}

resource "azurerm_lb_rule" "rule" {
  for_each = var.loadbalancers

  name                           = each.value.rules[0].name
  protocol                       = each.value.rules[0].protocol
  frontend_port                  = each.value.rules[0].frontend_port
  backend_port                   = each.value.rules[0].backend_port

  loadbalancer_id                = azurerm_lb.ilb[each.key].id
  frontend_ip_configuration_name = "internal-frontend"

  backend_address_pool_ids = [
    azurerm_lb_backend_address_pool.backend[each.key].id]

  probe_id = azurerm_lb_probe.probe[each.key].id
}
