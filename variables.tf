variable "vm_name" {
  type        = string
  description = "vm name"
}
variable "admin_username" {
  type        = string
  description = "admin username for vm"
}
variable "admin_password" {
  type        = string
  sensitive   = true
  description = "admin password for vm"
}
variable "vm_size" {
  type        = string
  description = "size of the vm"
  default     = "Standard_B2s"
}
