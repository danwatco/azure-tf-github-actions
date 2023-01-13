# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  backend "azurerm" {
    resource_group_name  = "DevOps-RG"
    storage_account_name = "sacdevopsdw123"
    container_name       = "tfstate"
    key                  = "tf.state"
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

# resource "azurerm_resource_group" "hub-spoke-rg" {
#   name = "hub-spoke-rg"
#   location = var.location  
# }

# resource "azurerm_virtual_network" "vnet1" {
#   name                = "vnet1"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   address_space       = ["10.0.0.0/16"]

# }

# resource "azurerm_subnet" "default-subnet" {
#   name                 = "default_subnet"
#   resource_group_name  = var.resource_group_name
#   virtual_network_name = azurerm_virtual_network.vnet1.name
#   address_prefixes     = ["10.0.0.0/24"]
# }

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# module "default_vm" {
#   source = "./modules/defaultVM"

#   name = "vm-ubuntu"

#   location = var.location
#   resource_group_name = var.resource_group_name
#   subnet_id = azurerm_subnet.default-subnet.id
#   vm_username = "azureuser"
#   public_key = tls_private_key.ssh_key.public_key_openssh
# }