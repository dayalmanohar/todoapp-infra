locals {
  env = "dev"

  env_config = {
    dev = {
      location = "West US"
      rg_name  = "todo-dev-rg"
    }
    prod = {
      location = "East US"
      rg_name  = "todo-prod-rg"
    }
  }

  location = local.env_config[local.env].location
  rg_name  = local.env_config[local.env].rg_name

  tenant_id = "28c3654a-a897-4228-8e6a-099ee5e50a80"

  common_tags = {
    env     = local.env
    project = "todo"
    managed = "terraform"
  }
}
