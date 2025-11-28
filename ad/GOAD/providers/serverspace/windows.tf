# t2.medium = 2cpu / 4GB
# t2.large  = 2cpu / 8GB
# t2.xlarge = 4cpu / 16GB
"dc01" = {
  name               = "dc01"
  domain             = "sevenkingdoms.local"
  windows_sku        = "2019-Datacenter"
  ami                = "Windows-Server 2019-X64"
  instance_type      = "t2.medium"
  private_ip_address = "{{ip_range}}.10"
  password           = "8dCT-DJjgScp"
  delay              = "80s"
}
"dc02" = {
  name               = "dc02"
  domain             = "north.sevenkingdoms.local"
  windows_sku        = "2019-Datacenter"
  ami                = "Windows-Server 2019-X64"
  instance_type      = "t2.medium"
  private_ip_address = "{{ip_range}}.11"
  password           = "NgtI75cKV+Pu"
  delay              = "95s"
}
#Changed 2016 to 2019
"dc03" = {
  name               = "dc03"
  domain             = "essos.local"
  windows_sku        = "2019-Datacenter"
  ami                = "Windows-Server 2019-X64"
  instance_type      = "t2.medium"
  private_ip_address = "{{ip_range}}.12"
  password           = "Ufe-bVXSx9rk"
  delay              = "110s"
}
"srv02" = {
  name               = "srv02"
  domain             = "north.sevenkingdoms.local"
  windows_sku        = "2019-Datacenter"
  ami                = "Windows-Server 2019-X64"
  instance_type      = "t2.medium"
  private_ip_address = "{{ip_range}}.22"
  password           = "NgtI75cKV+Pu"
  delay              = "125s"
}
#Changed 2016 to 2019
"srv03" = {
  name               = "srv03"
  domain             = "essos.local"
  windows_sku        = "2019-Datacenter"
  ami                = "Windows-Server 2019-X64"
  instance_type      = "t2.medium"
  private_ip_address = "{{ip_range}}.23"
  password           = "978i2pF43UJ-"
  delay              = "170s"
}