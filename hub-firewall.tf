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

}

resource "azurerm_firewall_policy" "hub-fw-policy" {
  location            = local.hub-location
  name                = "hub-fw-policy"
  resource_group_name = local.hub-resource-group
}

# resource "azurerm_firewall_policy_rule_collection_group" "hub-fw-collection" {
#   firewall_policy_id = azurerm_firewall_policy.hub-fw-policy.id
#   name               = "hub-fw-collection"
#   priority           = 100

#   application_rule_collection {
#     name     = "app-coll-01"
#     priority = 500
#     action   = "Allow"
#     rule {
#       name = "Allow-Google"
#       protocols {
#         type = "Http"
#         port = 80
#       }
#       protocols {
#         type = "Https"
#         port = 443
#       }
#       source_addresses  = ["10.1.0.0/16"]
#       destination_fqdns = ["www.google.com"]
#     }
#   }
# }