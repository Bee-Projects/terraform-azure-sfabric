output "reource_group_name" {
    value = "${local.resource_group_name}"
}

output "explorer_ui" {
    value = "http://${azurerm_public_ip.sfabric-ip.fqdn}"
}

output "app_ui" {
    value = "http://${azurerm_public_ip.app-ip.fqdn}"
}