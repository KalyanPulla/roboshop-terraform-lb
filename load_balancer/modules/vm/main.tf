resource "azurerm_network_interface" "main" {
  count               = var.vm_count 
  name                = "${var.component_name}-${var.env}-${count.index}"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  ip_configuration {
    name                          = "${var.component_name}-${var.env}-nic${count.index}"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  count                 = var.vm_count 
  name                  = "${var.component_name}-${var.env}-vm${count.index}"
  location              = data.azurerm_resource_group.main.location
  resource_group_name   = data.azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.main[count.index].id]
  size                  = "Standard_B2ts_v2"

  source_image_id = var.image_id

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_username = "devops"
  admin_password = "devops@12345"

  disable_password_authentication = false

  secure_boot_enabled = true
  vtpm_enabled        = true
}

resource "azurerm_dns_a_record" "main" {
  name                = "${var.component_name}-${var.env}"
  zone_name           = "kaldevops14.online"
  resource_group_name = data.azurerm_resource_group.main.name
  ttl                 = 30
  records             = var.lb_type == null ? [azurerm_network_interface.main[0].private_ip_address] : var.lb_type == "public" ? azurerm_public_ip.main[*].ip_address : azurerm_lb.main[*].private_ip_address
}

resource "azurerm_public_ip" "main" {
  count                 = var.lb_type == "public" ? 1 : 0
  name                  = "${var.component_name}-${var.env}"
  location              = data.azurerm_resource_group.main.location
  resource_group_name   = data.azurerm_resource_group.main.name
  allocation_method     = "Static"
}

resource "azurerm_lb" "main" {
  count                 = var.lb_type != null ? 1 : 0
  name                  = "${var.component_name}-${var.env}-lb"
  location              = data.azurerm_resource_group.main.location
  resource_group_name   = data.azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                = "${var.component_name}-${var.env}"
    private_ip_address_allocation = var.lb_type == "private" ? "Dynamic" : null
    subnet_id = var.lb_type == "private" ? var.subnet_id : null
    public_ip_address_id = var.lb_type == "public" ? azurerm_public_ip.main[0].id : null
  }
}

resource "azurerm_lb_backend_address_pool" "main" {
  count                 = var.lb_type != null ? 1 : 0
  loadbalancer_id = azurerm_lb.main[0].id
  name            = "BackEndAddressPool"
}
resource "azurerm_lb_backend_address_pool_address" "main" {
  count                 = var.lb_type != null ? var.vm_count : 0
  name                    = "${var.component_name}-${var.env}-${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main[0].id
  virtual_network_id = "/subscriptions/396632f7-adca-488d-bb48-22d93391890f/resourceGroups/denmark-east-rg/providers/Microsoft.Network/virtualNetworks/vnet-denmarkeast-1"
  ip_address = azurerm_network_interface.main[count.index].private_ip_address
}

resource "azurerm_lb_rule" "main" {
  count                 = var.lb_type != null ? 1 : 0
  loadbalancer_id                = azurerm_lb.main[0].id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = var.port
  backend_port                   = var.port
  frontend_ip_configuration_name = "${var.component_name}-${var.env}"
}