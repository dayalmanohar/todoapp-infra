variable "loadbalancers" {
  description = "Internal Load Balancers"
  type = map(object({
    name                = string
    location            = string
    resource_group_name = string

    subnet_id           = string
    frontend_ip_name    = string
    frontend_private_ip = optional(string) # Static optional

    backend_pool_name   = string
    probe = object({
      name     = string
      protocol = string
      port     = number
    })

    rules = list(object({
      name           = string
      protocol       = string
      frontend_port  = number
      backend_port   = number
    }))

    tags = map(string)
  }))
}
