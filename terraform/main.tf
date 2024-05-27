terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.7.0"
    }
    local ={
      source = "hashicorp/local"
    }
  }

  required_version = ">= 0.13.4"
  
  backend "azurerm" {
    resource_group_name  = "boujenna_selma-rg"  
    storage_account_name = "prov123"
    container_name =     = "storagecontainer"                                
    key                  = "prod.terraform.tfstate"                
    use_oidc             = true                                    
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "boujenna_selma-rg" {
  name = "boujenna_selma-rg"
}

resource "azurerm_virtual_network" "provisioning-vnet" {
  name                = "${var.resource_prefix}-vnet"
  address_space       = var.node_addres_space
  location            = var.node_location
  resource_group_name = var.node_rgname
}

resource "azurerm_subnet" "provisioning-subnet" {
  name                 = "${var.resource_prefix}-subnet"
  resource_group_name  = var.node_rgname
  virtual_network_name = azurerm_virtual_network.provisioning-vnet.name
  address_prefixes     = var.node_address_prefix
}

resource "azurerm_network_security_group" "provisioning-nsg" {
  name                = "${var.resource_prefix}-nsg"
  location            = var.node_location
  resource_group_name = var.node_rgname
}

resource "azurerm_network_security_rule" "security_rule" {
  name                        = "security_rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.node_rgname
  network_security_group_name = azurerm_network_security_group.provisioning-nsg.name
}

resource "azurerm_subnet_network_security_group_association" "sub_associations" {
  subnet_id                 = azurerm_subnet.provisioning-subnet.id
  network_security_group_id = azurerm_network_security_group.provisioning-nsg.id
}

resource "azurerm_public_ip" "provisioning_public_ip" {
  count               = var.node_count
  name                = "${var.resource_prefix}-ipconfig-${count.index}"
  resource_group_name = var.node_rgname
  location            = var.node_location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "provisioning-nic" {
  count               = var.node_count
  name                = "${var.resource_prefix}-nic-${count.index}"
  location            = var.node_location
  resource_group_name = var.node_rgname

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.provisioning-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.provisioning_public_ip.*.id, count.index)
  }
}

resource "azurerm_linux_virtual_machine" "linux_vm" {
  count                 = var.node_count
  name                  = "${var.resource_prefix}-${count.index}"
  resource_group_name   = var.node_rgname
  location              = var.node_location
  size                  = "Standard_F2s_v2"
  admin_username        = "adminuser"
  network_interface_ids = [element(azurerm_network_interface.provisioning-nic.*.id, count.index)]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("/home/adminuser/.ssh/azurekey.pub")
  }

  os_disk {
    name                 = "myosdisk-${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "SUSE"
    offer     = "openSUSE-leap-15-4"
    sku       = "gen2"
    version   = "latest"
  }
}

data "azurerm_public_ip" "provisioning_public_ip"{
  name = azurerm_public_ip.provisioning_public_ip[0].name
  resource_group_name = azurerm_linux_virtual_machine.linux_vm[0].resource_group_name
}

data "azurerm_public_ip" "provisioning_public_ip1"{
  name = azurerm_public_ip.provisioning_public_ip[1].name
  resource_group_name = azurerm_linux_virtual_machine.linux_vm[1].resource_group_name
}

data "azurerm_public_ip" "provisioning_public_ip2"{
  name = azurerm_public_ip.provisioning_public_ip[2].name
  resource_group_name = azurerm_linux_virtual_machine.linux_vm[2].resource_group_name
}

locals {
  my_first_ip = data.azurerm_public_ip.provisioning_public_ip.ip_address
  my_second_ip =data.azurerm_public_ip.provisioning_public_ip1.ip_address
  my_third_ip = data.azurerm_public_ip.provisioning_public_ip2.ip_address
  testingVM = "[testingVM]"
  acceptanceVM = "[acceptanceVM]"
  productionVM = "[productionVM]"  
}

resource "execute" "prepare_directory" {
  provisioner "local-exec" {
    command = "chmod 755 /home/adminuser/temp/ansible_quickstart"
  }
}

resource "local_file" "ansible" {
  filename = "/home/adminuser/temp/ansible_quickstart/inventory"
  content = <<-EOT
  ${local.testingVM}
  ${data.azurerm_public_ip.provisioning_public_ip.ip_address} ansible_user=adminuser
  ${local.acceptanceVM}
  ${data.azurerm_public_ip.provisioning_public_ip1.ip_address} ansible_user=adminuser
  ${local.productionVM}
  ${data.azurerm_public_ip.provisioning_public_ip2.ip_address} ansible_user=adminuser
  EOT
}

