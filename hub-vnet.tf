locals {
    prefix-hub = "hub"
    hub-location = "westeurope"
    hub-resource-group = "hub-spoke-rg"
}

resource "azurerm_virtual_network" "hub-vnet" {
    address_space = [ "10.0.0.0/16" ]
    location = local.hub-location
    name = "${local.prefix-hub}-vnet"
    resource_group_name = local.hub-resource-group

    # depends_on = [azurerm_resource_group.hub-spoke-rg]    
}

resource "azurerm_subnet" "hub-mgmt" {
    address_prefixes = [ "10.0.0.64/27" ]
    name = "mgmt"
    resource_group_name = local.hub-resource-group
    virtual_network_name = azurerm_virtual_network.hub-vnet.name    
}

resource "azurerm_subnet" "hub-dmz" {
    address_prefixes = [ "10.0.0.32/27" ]
    name = "dmz"
    resource_group_name = local.hub-resource-group
    virtual_network_name = azurerm_virtual_network.hub-vnet.name    
}

resource "azurerm_subnet" "hub-bastion" {
    address_prefixes = [ "10.0.1.0/26" ]
    name = "AzureBastionSubnet"
    resource_group_name = local.hub-resource-group
    virtual_network_name = azurerm_virtual_network.hub-vnet.name
    
}

resource "azurerm_subnet" "hub-firewall" {
    address_prefixes = [ "10.0.2.0/26" ]
    name = "AzureFirewallSubnet"
    resource_group_name = local.hub-resource-group
    virtual_network_name = azurerm_virtual_network.hub-vnet.name
    
}

# Jumpbox VM
module "hub_vm" {
    source = "./modules/defaultVM"

    name = "${local.prefix-hub}-vm"
    location = local.hub-location
    resource_group_name = local.hub-resource-group
    subnet_id = azurerm_subnet.hub-mgmt.id
    vm_username = "azureuser"
    public_key = tls_private_key.ssh_key.public_key_openssh
}

#Bastion
resource "azurerm_public_ip" "bastion-ip" {
    allocation_method = "Static"
    location = local.hub-location
    name = "pip-bastion"
    resource_group_name = local.hub-resource-group
    sku = "Standard"
}

resource "azurerm_bastion_host" "bastion-host" {
    location = local.hub-location
    name = "hub-bastion-host"
    resource_group_name = local.hub-resource-group
    
    sku = "Standard"
    ip_configuration {
        name = "hub-bastion-host-ip-cfg"
        subnet_id = azurerm_subnet.hub-bastion.id
        public_ip_address_id = azurerm_public_ip.bastion-ip.id
    }
}
