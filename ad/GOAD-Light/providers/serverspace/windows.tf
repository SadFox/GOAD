"dc01" = {
  name               = "dc01"
  domain             = "sevenkingdoms.local"
  windows_sku        = "2019-Datacenter"
  ami                = "Windows-Server 2019-X64"
  instance_type      = "t2.medium"
  private_ip_address = "{{ip_range}}.10"
  password           = "8dCT-DJjgScp"
  delay              = "20s"
}
"dc02" = {
  name               = "dc02"
  domain             = "north.sevenkingdoms.local"
  windows_sku        = "2019-Datacenter"
  ami                = "Windows-Server 2019-X64"
  instance_type      = "t2.medium"
  private_ip_address = "{{ip_range}}.11"
  password           = "NgtI75cKV+Pu"
  delay              = "35s"
}
"srv02" = {
  name               = "srv02"
  domain             = "north.sevenkingdoms.local"
  windows_sku        = "2019-Datacenter"
  ami                = "Windows-Server 2019-X64"
  instance_type      = "t2.medium"
  private_ip_address = "{{ip_range}}.22"
  password           = "NgtI75cKV+Pu"
  delay              = "50s"
}