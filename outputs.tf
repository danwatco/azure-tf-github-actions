# output "resource_group_name" {
#     value = var.resource_group_name
# }

# output "public_ip_address" {
#   value = module.default_vm.public_ip_address
# }

output "tls_private_key" {
    value = tls_private_key.ssh_key.private_key_pem
    sensitive = true
}