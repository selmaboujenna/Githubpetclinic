variable "node_location" {
  default = "westeurope"
}
variable "node_rgname" {
  default = "boujenna_selma-rg"
}

variable "resource_prefix" {
  default = "provisioning"
}

variable "node_addres_space" {
  default = ["10.123.0.0/16"]
}

variable "node_address_prefix" {
  default = ["10.123.0.0/24"]
}

variable "Environment" {
  default = "dev"
}

variable "node_count" {
  type = number
  default = 3
}
