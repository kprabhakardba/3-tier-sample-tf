resource "azurerm_availability_set" "web_availabilty_set" {
  name                = "web_availabilty_set"
  location            = var.location
  resource_group_name = var.resource_group
}

resource "azurerm_network_interface" "web-net-interface" {
  name                = "web-network"
  resource_group_name = var.resource_group
  location            = var.location

  ip_configuration {
    name                          = "web-webserver"
    subnet_id                     = var.web_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "web-vm" {
  name                          = "web-vm"
  location                      = var.location
  resource_group_name           = var.resource_group
  network_interface_ids         = [azurerm_network_interface.web-net-interface.id]
  availability_set_id           = azurerm_availability_set.web_availabilty_set.id
  vm_size                       = "Standard_D2s_v3"
  delete_os_disk_on_termination = true
  depends_on = [
    azurerm_key_vault_access_policy.example-disk, azurerm_key_vault_access_policy.example-user, azurerm_disk_encryption_set.example
  ]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "web-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = var.web_host_name
    admin_username = var.web_username
    admin_password = var.web_os_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}


resource "azurerm_availability_set" "app_availabilty_set" {
  name                = "app_availabilty_set"
  location            = var.location
  resource_group_name = var.resource_group
}

resource "azurerm_network_interface" "app-net-interface" {
  name                = "app-network"
  resource_group_name = var.resource_group
  location            = var.location

  ip_configuration {
    name                          = "app-webserver"
    subnet_id                     = var.app_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "app-vm" {
  name                          = "app-vm"
  location                      = var.location
  resource_group_name           = var.resource_group
  network_interface_ids         = [azurerm_network_interface.app-net-interface.id]
  availability_set_id           = azurerm_availability_set.web_availabilty_set.id
  vm_size                       = "Standard_D2s_v3"
  delete_os_disk_on_termination = true
  depends_on = [
    azurerm_key_vault_access_policy.example-disk, azurerm_key_vault_access_policy.example-user, azurerm_disk_encryption_set.example
  ]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "app-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = var.app_host_name
    admin_username = var.app_username
    admin_password = var.app_os_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_managed_disk" "app" {
  name                   = "app-data"
  location               = "centralus"
  resource_group_name    = var.resource_group
  storage_account_type   = "Standard_LRS"
  create_option          = "Empty"
  disk_size_gb           = "32"
  disk_encryption_set_id = azurerm_disk_encryption_set.example.id

  tags = {
    environment = "staging"
  }
}

resource "azurerm_managed_disk" "web" {
  name                   = "web-data"
  location               = "centralus"
  resource_group_name    = var.resource_group
  storage_account_type   = "Standard_LRS"
  create_option          = "Empty"
  disk_size_gb           = "32"
  disk_encryption_set_id = azurerm_disk_encryption_set.example.id
  tags = {
    environment = "staging"
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "app" {
  managed_disk_id    = azurerm_managed_disk.app.id
  virtual_machine_id = azurerm_virtual_machine.app-vm.id
  lun                = "10"
  caching            = "ReadWrite"
}

resource "azurerm_virtual_machine_data_disk_attachment" "web" {
  managed_disk_id    = azurerm_managed_disk.web.id
  virtual_machine_id = azurerm_virtual_machine.web-vm.id
  lun                = "10"
  caching            = "ReadWrite"
}