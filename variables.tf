variable "region" {
  default = "AustraliaEast"
}

variable "subnet1" {
  default = "10.0.2.0/24"
}
resource "random_string" "postfix" {
  length = 8
  special = false
  upper = false
}

locals  {
  resource_group_name = "sfabric-rg-${random_string.postfix.result}"
  app-dns = "apps-${random_string.postfix.result}"
  sfabric-dns = "sfabric-${random_string.postfix.result}"
}

variable "vnet_name" {
  default = "sfabric-net"
}


variable "frontend_sfabric" {
   default = "sfabric-ip"
}

variable "frontend_app" {
   default = "app-ip"
}

