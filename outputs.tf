output "reource_group_name" {
  description = "Name of the resource group where all the sfabric resources are created"
  value       = "${local.resource_group_name}"
}

output "explorer_ui" {
  description = "URL for the sfabric UI"
  value       = "http://${azurerm_public_ip.sfabric-ip.fqdn}"
}

output "app_ui" {
  description = "URL for the APP UI"
  value       = "http://${azurerm_public_ip.app-ip.fqdn}"
}
