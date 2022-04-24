resource "azurerm_network_security_group" "appgw-nsg" {
  name                = "appgw-nsg"
  location            = var.location
  resource_group_name = var.resource_group

  security_rule {
    name                       = "AzureLoadBalancer"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "192.168.1.0/24"
    destination_port_range     = "80"
  }

  security_rule {
    name                       = "WebtoALB"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "192.168.1.0/24"
    source_port_range          = "*"
    destination_address_prefix = "192.168.0.0/24"
    destination_port_range     = "80"
  }
}

resource "azurerm_subnet_network_security_group_association" "web-alb-subnet" {
  subnet_id                 = var.web_subnet_id
  network_security_group_id = azurerm_network_security_group.appgw-nsg.id
}

resource "azurerm_network_security_group" "web-app-nsg" {
  name                = "web-nsg"
  location            = var.location
  resource_group_name = var.resource_group

  security_rule {
    name                       = "web2app"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "192.168.1.0/24"
    source_port_range          = "*"
    destination_address_prefix = "192.168.2.0/24"
    destination_port_range     = "80"
  }

  security_rule {
    name                       = "app2web"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "192.168.2.0/24"
    source_port_range          = "*"
    destination_address_prefix = "192.168.1.0/24"
    destination_port_range     = "80"
  }

  security_rule {
    name                       = "Outapp2web"
    priority                   = 101
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "192.168.2.0/24"
    source_port_range          = "*"
    destination_address_prefix = "192.168.1.0/24"
    destination_port_range     = "80"
  }
}

resource "azurerm_subnet_network_security_group_association" "web-nsg-subnet" {
  subnet_id                 = var.web_subnet_id
  network_security_group_id = azurerm_network_security_group.web-app-nsg.id
}

resource "azurerm_subnet_network_security_group_association" "app-nsg-subnet" {
  subnet_id                 = var.app_subnet_id
  network_security_group_id = azurerm_network_security_group.web-app-nsg.id
}

resource "azurerm_network_security_group" "db-nsg" {
  name                = "db-nsg"
  location            = var.location
  resource_group_name = var.resource_group

  security_rule {
    name                       = "ssh-rule-1"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "192.168.2.0/24"
    source_port_range          = "*"
    destination_address_prefix = "192.168.3.0/24"
    destination_port_range     = "3306"
  }

  security_rule {
    name                       = "ssh-rule-2"
    priority                   = 102
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "192.168.2.0/24"
    source_port_range          = "*"
    destination_address_prefix = "192.168.3.0/24"
    destination_port_range     = "3306"
  }

  security_rule {
    name                       = "ssh-rule-3"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_address_prefix      = "192.168.3.0/24"
    source_port_range          = "*"
    destination_address_prefix = "192.168.2.0/24"
    destination_port_range     = "3306"
  }
}

resource "azurerm_subnet_network_security_group_association" "db-nsg-subnet" {
  subnet_id                 = var.db_subnet_id
  network_security_group_id = azurerm_network_security_group.db-nsg.id
}