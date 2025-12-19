variable "bastions" {
  description = "Azure Bastion configuration"
  type = map(object({
    name                = string
    location            = string
    resource_group_name = string
    subnet_id           = string
    public_ip_id        = string
    tags                = map(string)
  }))
}
