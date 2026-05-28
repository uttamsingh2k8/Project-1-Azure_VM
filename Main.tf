resource "azurerm_resource_group" "dev" {
  name     = local.resource_group_name
  location = local.resource_location
}

resource "azurerm_virtual_network" "dev-vnetwork" {
  name                = local.virtual_network.name
  location            = local.resource_location
  resource_group_name = local.resource_group_name
  address_space       = local.virtual_network.address_prefixes

  tags = {
    environment = "Dev"
  }
}

resource "azurerm_subnet" "dev-subnet1" {
  name                 = local.subnet.subnet1.name
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.dev-vnetwork.name
  address_prefixes     = local.subnet.subnet1.address_prefixes
}

resource "azurerm_subnet" "dev-subnet2" {
  name                 = local.subnet.subnet2.name
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.dev-vnetwork.name
  address_prefixes     = local.subnet.subnet2.address_prefixes
}

resource "azurerm_network_interface" "dev-nic1" {
  name                = "dev-nic1"
  location            = local.resource_location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.dev-subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.dev-public-nic1.id
  }
}

resource "azurerm_public_ip" "dev-public-nic1" {
  name                = "dev-public-nic1"
  resource_group_name = local.resource_group_name
  location            = local.resource_location
  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "dev-nsg1" {
  name                = "dev-nsg1"
  location            = local.resource_location
  resource_group_name = local.resource_group_name

  security_rule {
    name                       = "Allow-RDP"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_subnet_network_security_group_association" "dev-subnet1-nsg1" {
  subnet_id                 = azurerm_subnet.dev-subnet1.id
  network_security_group_id = azurerm_network_security_group.dev-nsg1.id
}

resource "azurerm_subnet_network_security_group_association" "dev-subnet2-nsg1" {
  subnet_id                 = azurerm_subnet.dev-subnet2.id
  network_security_group_id = azurerm_network_security_group.dev-nsg1.id
}

resource "azurerm_windows_virtual_machine" "devwinCIvm1" {
  name                              = var.vm_name
  resource_group_name               = azurerm_resource_group.dev.name
  location                          = azurerm_resource_group.dev.location
  size                              = var.vm_size
  admin_username                    = var.admin_username
  admin_password                    = var.admin_password
  vm_agent_platform_updates_enabled = true
  network_interface_ids = [
    azurerm_network_interface.dev-nic1.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_managed_disk" "dev-dd1" {
  name                 = "dev-dd1"
  location             = local.resource_location
  resource_group_name  = local.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "4"
}
resource "azurerm_virtual_machine_data_disk_attachment" "dd-devwinCIvm1" {
  managed_disk_id    = azurerm_managed_disk.dev-dd1.id
  virtual_machine_id = azurerm_windows_virtual_machine.devwinCIvm1.id
  lun                = "0"
  caching            = "ReadWrite"
}
