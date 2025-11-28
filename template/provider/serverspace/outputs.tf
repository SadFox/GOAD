# Public IP of the jumpbox
output "ubuntu-jumpbox-ip" {
  value = serverspace_server.jumpbox.public_ip_addresses[0]
}

output "ubuntu-jumpbox-username" {
  value = var.jumpbox_username
}

# Keep the same shape used by GOAD tooling
output "vm-config" {
  value = var.vm_config
}

output "windows-vm-username" {
  value = var.username
}


