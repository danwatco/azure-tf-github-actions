# locals {
#     prefix-hub = "hub"
#     hub-location = "westeurope"
#     hub-resource-group = "hub-spoke-rg"
# }

resource "azurerm_public_ip" "pip-firewall" {
  allocation_method   = "Static"
  location            = local.hub-location
  name                = "pip-fw"
  resource_group_name = local.hub-resource-group
  sku                 = "Standard"

  depends_on = [azurerm_resource_group.hub-rg]
}

resource "azurerm_firewall" "hub-firewall" {
  location            = local.hub-location
  name                = "hub-firewall"
  resource_group_name = local.hub-resource-group
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "hub-firewall-ip-cfg"
    subnet_id            = azurerm_subnet.hub-firewall.id
    public_ip_address_id = azurerm_public_ip.pip-firewall.id
  }

  depends_on = [azurerm_resource_group.hub-rg]

}

resource "azurerm_firewall_policy" "hub-fw-policy" {
  location            = local.hub-location
  name                = "hub-fw-policy"
  resource_group_name = local.hub-resource-group
}

resource "azurerm_firewall_policy_rule_collection_group" "hub-fw-collection" {
  firewall_policy_id = azurerm_firewall_policy.hub-fw-policy.id
  name               = "hub-fw-collection"
  priority           = 100

  application_rule_collection {
    name     = "app-coll-01"
    priority = 200
    action   = "Allow"
    rule {
      name = "Allow-Google"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["*.google.com"]
    }
    rule {
      name = "Allow-Internet"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses = ["10.2.1.0/24"]
      destination_fqdns = ["*"] 
    }
  }

  network_rule_collection {
    name = "network-coll-01"
    priority = 200
    action = "Allow"
    rule {
      name = "Allow-Spoke1-Spoke2"
      protocols = ["TCP", "UDP", "ICMP"]
      source_addresses = ["10.1.1.0/24"]
      destination_addresses = ["10.2.1.0/24"]
      destination_ports = ["1-65535"]
    }
    rule {
      name = "Allow-Spoke2-Spoke1"
      protocols = ["TCP", "UDP", "ICMP"]
      source_addresses = ["10.2.1.0/24"]
      destination_addresses = ["10.1.1.0/24"]
      destination_ports = ["1-65535"]
    }
    rule {
      name = "Allow-Internet"
      protocols = ["TCP", "UDP"]
      source_addresses = ["10.2.1.0/24"]
      destination_addresses = ["Internet"]
      destination_ports = ["80", "443"]
    }
  }
}