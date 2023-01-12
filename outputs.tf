output "resource_group_name" {
    value = var.resource_group_name
}

output "public_ip_address" {
  value = module.default_vm.public_ip_address
}

output "tls_private_key" {
    value = module.default_vm.tls_private_key
    sensitive = true
}