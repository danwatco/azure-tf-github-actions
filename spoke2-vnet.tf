locals {
    prefix-spoke2 = "spoke2"
    spoke2-location = "westeurope"
    spoke2-resource-group = "hub-spoke-rg"
}

resource "azurerm_virtual_network" "spoke2-vnet" {
    address_space = [ "10.2.0.0/16" ]
    location = local.spoke2-location
    name = "spoke2-vnet"
    resource_group_name = local.spoke2-resource-group  

    # depends_on = [azurerm_resource_group.hub-spoke-rg]   
}

resource "azurerm_subnet" "spoke2-mgmt" {
    address_prefixes = [ "10.2.1.0/24" ]
    name = "mgmt"
    resource_group_name = local.spoke2-resource-group
    virtual_network_name = azurerm_virtual_network.spoke2-vnet.name
}

resource "azurerm_virtual_network_peering" "spoke2-hub-peer" {
    name = "spoke2-hub-peer"
    remote_virtual_network_id = azurerm_virtual_network.hub-vnet.id
    resource_group_name = local.spoke2-resource-group
    virtual_network_name = azurerm_virtual_network.spoke2-vnet.name

    allow_virtual_network_access = true
    allow_forwarded_traffic = true
    
    depends_on = [azurerm_virtual_network.spoke2-vnet, azurerm_virtual_network.hub-vnet]
    
}

resource "azurerm_virtual_network_peering" "hub-spoke2-peer" {
    name                      = "hub-spoke2-peer"
    resource_group_name       = local.hub-resource-group
    virtual_network_name      = azurerm_virtual_network.hub-vnet.name
    remote_virtual_network_id = azurerm_virtual_network.spoke2-vnet.id
    
    allow_virtual_network_access = true
    allow_forwarded_traffic   = true

    depends_on = [azurerm_virtual_network.spoke2-vnet, azurerm_virtual_network.hub-vnet]
}

module "spoke2-vm" {
    source = "./modules/defaultVM"

    name = "${local.prefix-spoke2}-vm"
    location = local.spoke2-location
    resource_group_name = local.spoke2-resource-group
    subnet_id = azurerm_subnet.spoke2-mgmt.id
    vm_username = "azureuser"
    public_key = tls_private_key.ssh_key.public_key_openssh
}