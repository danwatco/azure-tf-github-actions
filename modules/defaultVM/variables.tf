variable "location" {
    description = "Region of deployed VM"
    type = string
}

variable "name" {
  description = "VM name"
  type = string
}

variable "resource_group_name" {
  description = "Resource group to deploy to"
  type = string
}

variable "subnet_id" {
  description = "Subnet to connect VM to"
}

variable "vm_username" {
  description = "Username for VMs"
  type = string
}

# variable "vm_password" {
#   description = "Password for VMs"
#   type = string
# }

variable "public_key" {
  description = "Access public key for VM ssh"
}