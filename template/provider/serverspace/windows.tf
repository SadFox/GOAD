resource "tls_private_key" "windows" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

variable "inventory_path" {
  type        = string
  default     = "../inventory"
  description = "Путь к INI inventory Ansible"
}

resource "local_file" "instance_init" {
  for_each = var.vm_config

  filename = "../instance-init-scripts/instance-init-${each.key}.ps1"

  content = templatefile("./instance-init.ps1.tpl", {
    username = var.username
    password = each.value.password
    domain   = each.value.domain
  })
}

resource "serverspace_server" "goad_vm" {
  for_each = var.vm_config

  depends_on = [serverspace_isolated_network.goad_net, time_sleep.before_instance]

  name             = "{{lab_identifier}}-${each.value.name}"
  location         = var.region
  image            = try(each.value.ami, var.win_image)
  cpu              = var.win_cpu
  ram              = var.win_ram
  boot_volume_size = var.win_boot_mb

  nic {
    network      = serverspace_isolated_network.goad_net.id
    network_type = "Isolated"
    bandwidth    = 0
  }
}

resource "time_sleep" "before_instance" {
  for_each = var.vm_config

  # общая задержка для всех
  create_duration = each.value.delay
}


resource "null_resource" "update_inventory" {
  for_each = var.vm_config

  depends_on = [serverspace_server.goad_vm]

  provisioner "local-exec" {
    interpreter = ["/usr/bin/env", "bash", "-lc"]

    environment = {
      INVENTORY_PATH = var.inventory_path
      VM_KEY         = each.key
      VM_IP          = one([
                            for n in serverspace_server.goad_vm[each.key].nic :
                            n.ip_address if n.network_type == "Isolated"
                          ])
    }

    command = <<-BASH
      set -euo pipefail

      inv="$INVENTORY_PATH"
      [ -f "$inv" ] || { echo "ERROR: inventory file not found: $inv" >&2; exit 1; }

      lock_file="$inv.lock"
      {
        exec 9>"$lock_file"
        flock 9

        sed -E -i'' "s/^($VM_KEY[[:space:]]+ansible_host=)[^[:space:]]+/\\1$VM_IP/" "$inv"
      }

      echo "Inventory updated: $inv"
    BASH
  }
}


resource "null_resource" "echo_rdp" {
  for_each = var.vm_config

  depends_on = [serverspace_server.goad_vm, serverspace_server.jumpbox]

  provisioner "local-exec" {
    interpreter = ["/usr/bin/env", "bash", "-lc"]
    environment = {
      VM_KEY = each.key
      API_KEY        = var.s2_token
      GET_SERVER_CREDS = "s2util"
      BASTION_IP = try(one([for n in serverspace_server.jumpbox.nic : n.ip_address if n.network_type == "PublicShared"]), null)
      SERVERNAME = "{{lab_identifier}}-${each.value.name}"
      VM_IP = try(one([for n in serverspace_server.goad_vm[each.key].nic : n.ip_address if n.network_type == "Isolated"]), null)
    }

    command = <<-BASH

          CREDS="$("$GET_SERVER_CREDS" --api-key "$API_KEY" server info --server-name "$SERVERNAME")" || {
            echo "WARN: get_server_creds failed for $SERVERNAME" >&2
            exit 1
          }
          
          USERNAME="$(echo "$CREDS" | sed -n '1p')"
          PASSWORD="$(echo "$CREDS" | sed -n '2p')"
          SERVER_ID="$(echo "$CREDS" | sed -n '3p')"

          sleep 15

          ss2tunnel_winrm \
            --bastion-host "$BASTION_IP" \
            --bastion-port 22 \
            --bastion-user goad \
            --bastion-key "$(pwd)/../ssh_keys/ubuntu-jumpbox.pem" \
            --win-host "$VM_IP" \
            --win-port 5985 \
            --win-user "$USERNAME" \
            --win-password "$PASSWORD" \
            --commands-file "$(pwd)/../instance-init-scripts/instance-init-$VM_KEY.ps1" \
            --log-file "$(pwd)/../instance-init-scripts/ss2tunnel-$VM_KEY.log"
          
      BASH
  }
}