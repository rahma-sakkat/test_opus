provider "azurerm" {
  features {}

  subscription_id = "613d8db0-49cd-47a5-af2f-4956bf6a8d5d"  # your subscription
  # optional but recommended if you know them:
  tenant_id       = "d5b5bfcf-d099-4fde-981f-0f0618bccdec"
}

resource "azurerm_resource_group" "rg" {
  name     = "test-opus-rg"
  location = "France Central"
}

resource "azurerm_mysql_flexible_server" "mysql" {
  name                   = "testopus-mysql"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  version                = "8.0.21"
  administrator_login    = "adminuser"
  administrator_password = "SuperSecret123!"
  sku_name               = "B_Standard_B1ms"
  backup_retention_days  = 7
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "test-opus-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "test-opus-aks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }
}
