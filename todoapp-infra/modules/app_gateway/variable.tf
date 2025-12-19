variable "app_gateways" {
  type = map(object({
    name                = string
    location            = string
    resource_group_name = string

    subnet_id    = string
    public_ip_id = string

    frontend_port = number

    frontend_ilb_ip = string
    backend_ilb_ip  = string

    tags = map(string)
  }))
}
