locals {
  resource_group_name = "dev-rg1"
  resource_location   = "Central India"
  virtual_network = {
    name             = "dev-vnetwork"
    address_prefixes = ["10.0.0.0/16"]
  }
  subnet = {
    subnet1 = {
      name             = "dev-subnet1"
      address_prefixes = ["10.0.1.0/24"]
    }
    subnet2 = {
      name             = "dev-subnet2"
      address_prefixes = ["10.0.2.0/24"]
    }
  }
}
