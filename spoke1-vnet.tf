locals {
    prefix-spoke1 = "spoke1"
    spoke1-location = "westeurope"
    spoke1-resource-group = "hub-spoke-rg"
}

resource "azurerm_virtual_network" "spoke1-vnet" {
    address_space = [ "10.1.0.0/16" ]
    location = local.spoke1-location
    name = "spoke1-vnet"
    resource_group_name = local.spoke1-resource-group    

    # depends_on = [azurerm_resource_group.hub-spoke-rg] 
}

resource "azurerm_subnet" "spoke1-mgmt" {
    address_prefixes = [ "10.1.1.0/24" ]
    name = "mgmt"
    resource_group_name = local.spoke1-resource-group
    virtual_network_name = azurerm_virtual_network.spoke1-vnet.name
}

resource "azurerm_virtual_network_peering" "spoke1-hub-peer" {
    name = "spoke1-hub-peer"
    remote_virtual_network_id = azurerm_virtual_network.hub-vnet.id
    resource_group_name = local.spoke1-resource-group
    virtual_network_name = azurerm_virtual_network.spoke1-vnet.name

    allow_virtual_network_access = true
    allow_forwarded_traffic = true
    
    depends_on = [azurerm_virtual_network.spoke1-vnet, azurerm_virtual_network.hub-vnet]
    
}

resource "azurerm_virtual_network_peering" "hub-spoke1-peer" {
    name                      = "hub-spoke1-peer"
    resource_group_name       = local.hub-resource-group
    virtual_network_name      = azurerm_virtual_network.hub-vnet.name
    remote_virtual_network_id = azurerm_virtual_network.spoke1-vnet.id
    allow_virtual_network_access = true
    allow_forwarded_traffic   = true
    allow_gateway_transit     = true
    use_remote_gateways       = false
    depends_on = [azurerm_virtual_network.spoke1-vnet, azurerm_virtual_network.hub-vnet]
}

module "spoke1-vm" {
    source = "./modules/defaultVM"

    name = "${local.prefix-spoke1}-vm"
    location = local.spoke1-location
    resource_group_name = local.spoke1-resource-group
    subnet_id = azurerm_subnet.spoke1-mgmt.id
    vm_username = "azureuser"
    public_key = tls_private_key.ssh_key.public_key_openssh
}