resource "azurerm_mssql_server" "primary" {
  name                         = var.primary_database
  resource_group_name          = var.resource_group
  location                     = var.location
  version                      = var.primary_database_version
  administrator_login          = var.primary_database_admin
  administrator_login_password = var.primary_database_password
}

resource "azurerm_mssql_database" "db" {
  name           = var.primary_database
  server_id      = azurerm_mssql_server.primary.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 4
  read_scale     = true
  sku_name       = "BC_Gen5_2"
  zone_redundant = true

  tags = {
    default = "Staging"
  }

}