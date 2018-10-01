provider "azurerm" { }



resource "azurerm_resource_group" "sfabric-rg" {
  name     = "${local.resource_group_name}"
  location = "${var.region}"
}

resource "azurerm_virtual_network" "sfabric-net" {
  name                = "${var.vnet_name}"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.sfabric-rg.location}"
  resource_group_name = "${local.resource_group_name}"
}

resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = "${local.resource_group_name}"
  virtual_network_name = "${azurerm_virtual_network.sfabric-net.name}"
  address_prefix       = "${var.subnet1}"
}

resource "azurerm_public_ip" "sfabric-ip" {
  name                         = "${var.frontend_sfabric}"
  location            = "${azurerm_resource_group.sfabric-rg.location}"
  resource_group_name = "${local.resource_group_name}"
  public_ip_address_allocation = "static"
  domain_name_label            = "${local.sfabric-dns}"

  tags {
    environment = "dev"
  }
}

resource "azurerm_public_ip" "app-ip" {
  name                         = "${var.frontend_app}"
  location            = "${azurerm_resource_group.sfabric-rg.location}"
  resource_group_name = "${local.resource_group_name}"
  public_ip_address_allocation = "static"
  domain_name_label            = "${local.app-dns}"

  tags {
    environment = "dev"
  }
}

resource "azurerm_lb" "sfabric-lb" {
  name                = "sfabric-lb"
  location            = "${azurerm_resource_group.sfabric-rg.location}"
  resource_group_name = "${local.resource_group_name}"

  frontend_ip_configuration {
    name                 = "${var.frontend_sfabric}"
    public_ip_address_id = "${azurerm_public_ip.sfabric-ip.id}"
  }

    frontend_ip_configuration {
    name                 = "${var.frontend_app}"
    public_ip_address_id = "${azurerm_public_ip.app-ip.id}"
  }
}

resource "azurerm_lb_probe" "sfabric-probe" {
  resource_group_name = "${local.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.sfabric-lb.id}"
  name                = "sfabric-probe"
  protocol            = "tcp"
  port                = "19080"
}

resource "azurerm_lb_probe" "app-probe" {
  resource_group_name = "${local.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.sfabric-lb.id}"
  name                = "app-probe"
  protocol            = "tcp"
  port                = "80"
}

resource "azurerm_lb_rule" "sfabric-rule" {
  resource_group_name            = "${local.resource_group_name}"
  loadbalancer_id                = "${azurerm_lb.sfabric-lb.id}"
  name                           = "sfabric-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 19080
  frontend_ip_configuration_name = "${var.frontend_sfabric}"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.backend.id}"
  probe_id                       = "${azurerm_lb_probe.sfabric-probe.id}"
}

resource "azurerm_lb_rule" "app-rule" {
  resource_group_name            = "${local.resource_group_name}"
  loadbalancer_id                = "${azurerm_lb.sfabric-lb.id}"
  name                           = "app-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "${var.frontend_app}"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.backend.id}"
  probe_id                       = "${azurerm_lb_probe.app-probe.id}"
}



resource "azurerm_lb_backend_address_pool" "backend" {
  resource_group_name = "${local.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.sfabric-lb.id}"
  name                = "backend"
}

resource "azurerm_lb_nat_pool" "lbnatpool" {
  count                          = 3
  resource_group_name            = "${local.resource_group_name}"
  name                           = "ssh"
  loadbalancer_id                = "${azurerm_lb.sfabric-lb.id}"
  protocol                       = "Tcp"
  frontend_port_start            = 50000
  frontend_port_end              = 50119
  backend_port                   = 22
  frontend_ip_configuration_name = "${var.frontend_sfabric}"
}

resource "azurerm_virtual_machine_scale_set" "sfabric-ss" {
  name                = "sfabric-ss"
  location            = "${azurerm_resource_group.sfabric-rg.location}"
  resource_group_name = "${local.resource_group_name}"
  upgrade_policy_mode = "Manual"

  sku {
    name     = "Standard_D2s_v3"
    tier     = "Standard"
    capacity = 1
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun            = 0
    caching        = "ReadWrite"
    create_option  = "Empty"
    disk_size_gb   = 100
  }

  os_profile {
    computer_name_prefix = "sfnode"
    admin_username       = "azureuser"
    admin_password       = "P@ssw0rd!@#"
    custom_data          = "${file("${path.module}/scripts/init.sh")}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = "${file("~/.ssh/id_rsa.pub")}"
    }

    
  }

  network_profile {
    name    = "sfnetworkprofile"
    primary = true

    ip_configuration {
      name                                   = "DevIPConfiguration"
      subnet_id                              = "${azurerm_subnet.subnet1.id}"
      load_balancer_backend_address_pool_ids = ["${azurerm_lb_backend_address_pool.backend.id}"]
      load_balancer_inbound_nat_rules_ids    = ["${element(azurerm_lb_nat_pool.lbnatpool.*.id, count.index)}"]
    }
  }

  tags {
    environment = "dev"
  }

}