variable "public_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = ["192.168.1.0/24", "192.168.2.0/24"]
}
 
variable "private_subnet_cidrs" {
 type        = list(string)
 description = "Private Subnet CIDR values"
 default     = ["192.168.127.0/24", "192.168.128.0/24"]
}

variable "azs" {
 type        = list(string)
 description = "Availability Zones"
 default     = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "db_username" {
  description = "Username for DB"
  type = string
  default = "admin"
  sensitive = true
}

variable "db_password" {
  description = "Password for DB"
  type = string
  default = "admin123456"
  sensitive = true
}