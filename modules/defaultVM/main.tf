resource "azurerm_public_ip" "tf_pip" {
  count               = var.public_ip ? 1 : 0
  name                = "pip-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "tf_nsg" {
  name                = "${var.name}-nsg1"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "tf_nic" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "${var.name}-nic-configuration"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip ? azurerm_public_ip.tf_pip[0].id : null
  }
}

resource "azurerm_network_interface_security_group_association" "nsg-nic" {
  network_interface_id      = azurerm_network_interface.tf_nic.id
  network_security_group_id = azurerm_network_security_group.tf_nsg.id
}


resource "azurerm_linux_virtual_machine" "tf_vm" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  network_interface_ids = [azurerm_network_interface.tf_nic.id]
  size                  = "Standard_B2s"

  os_disk {
    name                 = "${var.name}-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = var.name
  admin_username                  = var.vm_username
  # admin_password                  = var.vm_password
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.vm_username
    public_key = var.public_key
  }
}
