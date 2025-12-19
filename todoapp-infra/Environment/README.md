# todoapp-infra

Infrastructure as Code (IaC) repository for **Todo Application** using **Terraform** and **Azure DevOps Pipelines**.

---

## 📌 Tech Stack
- **Terraform** (Azure Provider)
- **Azure DevOps Pipelines**
- **Azure Resources**
  - Resource Group
  - Virtual Network & Subnets
  - NSG
  - Azure Firewall
  - Internal Load Balancer
  - Application Gateway
  - Bastion
  - Virtual Machines
  - Storage
  - SQL
  -

---

## 📁 Repository Structure

```text
todoapp-infra/
│
├── Environment/
│   ├── Dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── dev-pipeline.yml
│
├── modules/
│   ├── Network/
│   ├── NSG/
│   ├── NIC/
│   ├── VM/
│   ├── Firewall/
│   ├── Internal_Load_Balancer/
│   ├── App_Gateway/
│   └── Bastion/
│   └── Storage/
│   └── SQLServer/
│   └── SQLDatabase/
│
├── .gitignore
└── README.md


Deployment Flow
1.INIT – Initialize Terraform backend
2.SCAN – Security scanning (tfsec / Checkov)
3.PLAN – Terraform execution plan
4.APPLY – Deploy infrastructure to Azure

Azure DevOps Pipeline Stages
        INIT  →  SCAN  →  PLAN  →  APPLY

Pipeline file:
    Environment/Dev/dev-pipeline.yml

Backend Configuration
    Storage Account: Azure Storage
    Container: tfstate
    State File: dev.terraform.tfstate