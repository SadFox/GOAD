# ---------- Addressing ----------
# Base CIDR for the isolated network (used for all domain VMs)
variable "goad_cidr" {
  description = "Default CIDR for GOAD isolated network"
  type        = string
  default     = "{{ip_range}}.0/24"
}

# (Kept for compatibility with existing templates; not used directly by Serverspace)
variable "goad_private_cidr" {
  description = "Unused in Serverspace provider; reserved for compatibility"
  type        = string
  default     = "{{ip_range}}.0/26"
}
variable "goad_public_cidr" {
  description = "Unused in Serverspace provider; reserved for compatibility"
  type        = string
  default     = "{{ip_range}}.64/26"
}

# Whitelist for jumpbox access (kept for compatibility; enforce at OS level if needed)
variable "whitelist_cidr" {
  description = "CIDRs allowed to reach the Ubuntu jumpbox (OS-level firewall)"
  type        = set(string)
  default     = ["0.0.0.0/0"]
}

# ---------- Credentials ----------
variable "username" {
  description = "Username for local administrator of Windows VMs (used by provisioning)"
  type        = string
  default     = "Administrator"
}

variable "jumpbox_username" {
  description = "Username for jumpbox SSH user"
  type        = string
  default     = "goad"
}

# ---------- Images ----------
variable "ubuntu_image" {
  description = "Ubuntu image name in Serverspace"
  type        = string
  default     = "Ubuntu-22.04-X64"
}

variable "win_image" {
  description = "Windows image or snapshot name (recommend preconfigured golden image with WinRM)"
  type        = string
  default     = "Windows-Server 2019-X64"
}

# ---------- Sizes / resources ----------
variable "jumpbox_disk_size" {
  description = "Jumpbox root disk size in GiB"
  type        = number
  default     = 30
}

variable "jumpbox_cpu" {
  type    = number
  default = 2
}

variable "jumpbox_ram" {
  description = "Jumpbox RAM in MiB"
  type        = number
  default     = 2048
}

variable "jumpbox_public_bandwidth" {
  description = "Public NIC bandwidth for jumpbox in Mbps"
  type        = number
  default     = 50
}

variable "win_cpu" {
  description = "CPU cores for each Windows VM (Serverspace requires explicit CPU/RAM)"
  type        = number
  default     = 2
}

variable "win_ram" {
  description = "RAM (MiB) for each Windows VM"
  type        = number
  default     = 4096
}

variable "win_boot_mb" {
  description = "Boot volume size for Windows VMs (MiB)"
  type        = number
  default     = 61440
}

variable "linux_cpu" {
  description = "CPU cores for each Linux VM"
  type        = number
  default     = 2
}

variable "linux_ram" {
  description = "RAM (MiB) for each Linux VM"
  type        = number
  default     = 2048
}

variable "linux_boot_mb" {
  description = "Boot volume size for Linux VMs (MiB)"
  type        = number
  default     = 30720
}

# ---------- VM Maps from GOAD templating ----------

variable "vm_config" {
  description = "Windows VM map from GOAD templates (some AWS fields are ignored here)"
  type = map(object({
    name               = string
    domain             = string
    windows_sku        = string
    ami                = string     # used as Serverspace image
    instance_type      = string     # ignored
    private_ip_address = string     # used as target static IP later by provisioning
    password           = string     # ignored here; Windows prep should be done in golden image
    delay              = string
  }))
  default = {
    {{windows_vms}}
  }
}

variable "linux_vm_config" {
  description = "Linux VM map from GOAD templates (some AWS fields are ignored here)"
  type = map(object({
    name               = string
    linux_sku          = string
    linux_version      = string
    ami                = string     # used as Serverspace image
    instance_type      = string     # ignored
    private_ip_address = string     # used as target static IP later by provisioning
    password           = string     # ignored
    size               = string     # ignored
  }))
  default = {
    {{linux_vms}}
  }
}
