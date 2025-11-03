provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "test-opus-rg"
  location = "East US"
}

resource "azurerm_mysql_flexible_server" "mysql" {
  name                = "testopus-mysql"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  version             = "8.0.21"
  administrator_login = "adminuser"
  administrator_password = "SuperSecret123!"
  sku_name            = "B_Standard_B1ms"
  backup_retention_days = 7
}
