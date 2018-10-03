variable "region" {
  description = "Default Region for the sfabric cluster"
  default     = "AustraliaEast"
}

variable "address_space" {
  description = "Supernet address space where the sfabric cluster will be deployed"
  default     = "10.0.0.0/16"
}

variable "subnet1" {
  description = "Subnet Address space where the sfabric cluster will be deployed"
  default     = "10.0.2.0/24"
}

resource "random_string" "postfix" {
  length  = 8
  special = false
  upper   = false
}

locals {
  resource_group_name = "sfabric-rg-${random_string.postfix.result}"
  app-dns             = "apps-${random_string.postfix.result}"
  sfabric-dns         = "sfabric-${random_string.postfix.result}"
}

variable "vnet_name" {
  description = "Name for the vnet"
  default     = "sfabric-net"
}

variable "frontend_sfabric" {
  description = "Name for the Frontend service Fabric IP"
  default     = "sfabric-ip"
}

variable "frontend_app" {
  description = "Name for the App IP"
  default     = "app-ip"
}
