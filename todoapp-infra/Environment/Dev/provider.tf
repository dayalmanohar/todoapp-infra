terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.56.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "todoappinfrastg"
    storage_account_name = "todoappinfrastg"
    container_name       = "todoapp-infra-ctr"
    key                  = "dev.terraform.tfstate"
  }
}



provider "azurerm" {
  features {}
  subscription_id = "a46e2f32-e4a1-44bf-946c-f3fa4a273aa1"
}