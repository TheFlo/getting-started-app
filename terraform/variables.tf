variable "prefix" {
  type = string
  default = "todoapp-env"
  description = "Prefix of the resource names"
}

variable "resource_location" {
  type = string
  default = "francecentral"
  description = "Location of the resources"
}

variable "username" {
  type = string
  default = "azureadm"
  description = "VM local account username"
}