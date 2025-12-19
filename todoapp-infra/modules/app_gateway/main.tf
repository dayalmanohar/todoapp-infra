resource "azurerm_application_gateway" "agw" {
  for_each = var.app_gateways

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = each.value.subnet_id
  }

  frontend_ip_configuration {
    name                 = "public-frontend"
    public_ip_address_id = each.value.public_ip_id
  }

  frontend_port {
    name = "https-port"
    port = each.value.frontend_port
  }

  # Frontend Backend Pool
  backend_address_pool {
    name         = "frontend-backend-pool"
    ip_addresses = [each.value.frontend_ilb_ip]
  }

  # Backend Backend Pool
  backend_address_pool {
    name         = "backend-backend-pool"
    ip_addresses = [each.value.backend_ilb_ip]
  }

  backend_http_settings {
    name                  = "http-setting"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
    cookie_based_affinity = "Disabled"
  }

  http_listener {
    name                           = "https-listener"
    frontend_ip_configuration_name = "public-frontend"
    frontend_port_name             = "https-port"
    protocol                       = "Http"
  }

  url_path_map {
    name                               = "path-map"
    default_backend_address_pool_name  = "frontend-backend-pool"
    default_backend_http_settings_name = "http-setting"

    path_rule {
      name                       = "api-rule"
      paths                     = ["/api/*"]
      backend_address_pool_name  = "backend-backend-pool"
      backend_http_settings_name = "http-setting"
    }
  }

  request_routing_rule {
    name               = "routing-rule"
    rule_type          = "PathBasedRouting"
    http_listener_name = "https-listener"
    url_path_map_name  = "path-map"
    priority           = 100
  }

  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }

  tags = each.value.tags
}
