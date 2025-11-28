# Isolated network for GOAD (Serverspace)
#
# NOTE: Serverspace provider expects network_prefix + mask, so we split var.goad_cidr.
# Example: goad_cidr = "192.168.56.0/24" -> network_prefix="192.168.56.0", mask=24

locals {
  goad_prefix = split("/", var.goad_cidr)[0]
  goad_mask   = tonumber(split("/", var.goad_cidr)[1])
}

resource "serverspace_isolated_network" "goad_net" {
  location       = var.region
  name           = "{{lab_name}}-net"
  description    = "Isolated network for lab {{lab_identifier}}"
  network_prefix = local.goad_prefix
  mask           = local.goad_mask


  provisioner "local-exec" {
    interpreter = ["/usr/bin/env", "bash", "-lc"]
    environment = {
      API_KEY        = var.s2_token
      GET_SERVER_CREDS = "s2util"
      NETWORK_ID = serverspace_isolated_network.goad_net.id
      LOCATION = var.region
    }

    command = <<-BASH
          CREDS="$("$GET_SERVER_CREDS" --api-key "$API_KEY" gateway create --location-id $LOCATION --name {{lab_identifier}}-Gateway --network-ids "$NETWORK_ID" --bandwidth-mbps 60)" || {
            echo "WARN: get_server_creds failed for $server_name" >&2
            exit 1
          }
      BASH
  }
}
