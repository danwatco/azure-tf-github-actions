variable "location" {
    description = "Region of deployed VM"
    type = string
}

variable "resource_group_name" {
  description = "Resource group to deploy to"
  type = string
}

variable "subnet_id" {
    description = "Subnet to connect VM to"
    type = azurerm_subnet
}