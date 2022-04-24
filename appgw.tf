resource "azurerm_public_ip" "example" {
  name                = "appgw-pip"
  location            = module.resourcegroup.location_id
  resource_group_name = module.resourcegroup.resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_application_gateway" "appgw" {
  name                = "myappgateway"
  resource_group_name = module.resourcegroup.resource_group_name
  location            = module.resourcegroup.location_id

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = module.networking.appgwsubnet_id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.example.id
  }

  backend_address_pool {
    name         = local.backend_address_pool_name
    ip_addresses = ["192.168.1.4"]
    fqdns        = null
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}