variable "secrets" {
  type = map(object({
    name         = string
    value        = string

    kv_key       = string                     # comes from tfvars
    key_vault_id = optional(string)           # injected later in main.tf

    content_type = optional(string)
    tags         = optional(map(string), {})
  }))
}
