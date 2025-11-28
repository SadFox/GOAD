# SSH key for jumpbox
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "serverspace_ssh" "jumpbox_key" {
  name       = "{{lab_identifier}}-jumpbox-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

# Ubuntu jumpbox with two NICs: PublicShared + Isolated
resource "serverspace_server" "jumpbox" {
  name             = "ubuntu-jumpbox"
  location         = var.region
  image            = var.ubuntu_image
  cpu              = var.jumpbox_cpu
  ram              = var.jumpbox_ram
  boot_volume_size = var.jumpbox_disk_size * 1024

  # Public NIC
  nic {
    network_type = "PublicShared"
    network      = ""              # per provider example
    bandwidth    = var.jumpbox_public_bandwidth
  }

  # Isolated NIC
  nic {
    network      = serverspace_isolated_network.goad_net.id
    network_type = "Isolated"
    bandwidth    = 0
  }

    # Подключение для remote-exec
  connection {
    type        = "ssh"
    host        = self.public_ip_addresses[0]
    user        = "root"         
    private_key = tls_private_key.ssh.private_key_openssh
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "useradd -m -s /bin/bash ${var.jumpbox_username}",
      "echo '${var.jumpbox_username} ALL=(ALL) NOPASSWD:ALL' >/etc/sudoers.d/90-${var.jumpbox_username}",
      "chmod 440 /etc/sudoers.d/90-${var.jumpbox_username}",
      "mkdir -p /home/${var.jumpbox_username}/.ssh",
      "cp -f /root/.ssh/authorized_keys /home/${var.jumpbox_username}/.ssh/authorized_keys || true",
      "chown -R ${var.jumpbox_username}:${var.jumpbox_username} /home/${var.jumpbox_username}/.ssh",
      "chmod 700 /home/${var.jumpbox_username}/.ssh",
      "chmod 600 /home/${var.jumpbox_username}/.ssh/authorized_keys",
      "sudo apt-get update && sudo apt-get install -y rsync"
    ]
  }

  ssh_keys = [ serverspace_ssh.jumpbox_key.id ]

  # Export the key files for GOAD
  provisioner "local-exec" {
    command = "echo '${tls_private_key.ssh.private_key_openssh}' > ../ssh_keys/ubuntu-jumpbox.pem && echo '${tls_private_key.ssh.public_key_openssh}' > ../ssh_keys/ubuntu-jumpbox.pub && chmod 600 ../ssh_keys/*"
  }
}
