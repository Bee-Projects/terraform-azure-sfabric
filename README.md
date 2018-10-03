# Overview

Terraform module for creating a Service Fabric environments on Azure. This module is good for DEV Environments only. It is not production ready. This terraform [module](https://registry.terraform.io/modules/Bee-Projects/sfabric/azure) sets up the following deployment on Azure.

The module creates two "Frontend IP Configurations" for the Azure load balancer below - one attached to a `sfabric-ip` and another attached to a `app-ip`.



![Diagram](./images/Diagram.png)

The `sfabric-ip` targets port `19080` to serve up the Service Fabric Explorer UI. The same IP also has inbound NAT rules to allow SSH on to the single instance that is created in the VM Scale Set. The terraform module uses your `~/.id/rsa.pub` as the public key that is allowed SSH access on to the VM.

The `app-ip` targets port 80 on the Service Fabric node.  Any web application you deploy, therefore, can be access via the DNS associated with `app-ip`.

## Usage

To use the terraform module, copy and paste the following snippet

```
module "sfabric" {
  source  = "Bee-Projects/sfabric/azure"
  version = "0.1.1"
}
```


## Input Parameters

These variables have default values and don't have to be set to use this module. You may set these variables to override their default values. This module has no required variables.

| Variable Name    | Description                   | Default Value |
| ------           | ------                        | ------        |
| region           | Region                        | AustraliaEast |
| subnet1          | Subnet Address Range          | 10.0.2.0/24   |
| vnet_name        | VNet Name                     | sfabric-net   |
| address_space    | VNET Address Space            | 10.0.0.0/16   |
| frontend_sfabric | Fronend IP Configuration Name | sfabric_ip    |
| frontend_app     | App IP Configuration Name     | app_ip        |


## Output Parameters
The following are the output variables

| Variable Name       | Description                                                       |
| -----               | ----                                                              |
| resource_group_name | Name of the resource group that is created for the service fabric |
| app_ui              | URL for the APP UI                                                |
| explorer_ui         | URL for the sfabric UI                                            |
