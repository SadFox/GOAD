# Linux VMs

# Generate a unique SSH key per Linux VM (to mirror original behavior)
resource "tls_private_key" "linux" {
  for_each = var.linux_vm_config
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "serverspace_ssh" "linux" {
  for_each = var.linux_vm_config
  name       = "{{lab_identifier}}-${each.value.name}-key"
  public_key = tls_private_key.linux[each.key].public_key_openssh
}

resource "serverspace_server" "linux_vm" {
  for_each = var.linux_vm_config

  name             = "{{lab_identifier}}-${each.value.name}"
  location         = var.region
  image            = try(each.value.ami, var.ubuntu_image)
  cpu              = var.linux_cpu
  ram              = var.linux_ram
  boot_volume_size = var.linux_boot_mb

  # Only Isolated NIC
  nic {
    network      = serverspace_isolated_network.goad_net.id
    network_type = "Isolated"
    bandwidth    = 0
  }

  ssh_keys = [ serverspace_ssh.linux[each.key].id ]

  # Export per-host Linux SSH keypair files
  provisioner "local-exec" {
    command = <<EOT
mkdir -p ../ssh_keys
umask 077
echo '${tls_private_key.linux[each.key].private_key_openssh}' > ../ssh_keys/${each.value.name}_ssh
echo '${tls_private_key.linux[each.key].public_key_openssh}'  > ../ssh_keys/${each.value.name}_ssh.pub
chmod 600 ../ssh_keys/${each.value.name}_ssh ../ssh_keys/${each.value.name}_ssh.pub
EOT
  }
}
