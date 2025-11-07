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

resource "azurerm_container_group" "app" {
  name                = "opus-app-group"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  ip_address_type     = "Public"
  dns_name_label      = "opus-app-${random_string.suffix.result}"

  container {
    name   = "backend"
    image  = "${var.docker_username}/backend:latest"
    cpu    = "1"
    memory = "1.5"

    ports {
      port     = 3000
      protocol = "TCP"
    }

    environment_variables = {
      NODE_ENV   = "production"
      DB_HOST    = azurerm_mysql_flexible_server.mysql.fqdn
      DB_USER    = "adminuser"
      DB_PASSWORD = "SuperSecret123!"
    }
  }

  container {
    name   = "frontend"
    image  = "${var.docker_username}/frontend:latest"
    cpu    = "1"
    memory = "1.5"

    ports {
      port     = 80
      protocol = "TCP"
    }

    environment_variables = {
      API_URL = "http://${azurerm_container_group.app.ip_address}:3000"
    }
  }

  tags = {
    environment = "production"
  }
}


resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}