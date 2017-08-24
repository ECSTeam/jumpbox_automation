# Azure Jumpbox Automation

Use the provided script, `jumpbox_infra.sh`, in this repo to spin up an Azure Resource Group, vNET, Subnet, Security Group, NIC, and a Jumpbox Virtual Machine.

### Prerequisites

- Need the Azure `az` client installed
- Set your cloud, if you have not already done so:
  `az cloud set --name AzureCloud`
- Login: `az login`
- If you have access to more than one Azure Subscriptions, then run `azure account list` to view your Subscriptions and set the default to the Subscription where you want the Jumpbox installed.
> `az account set --subsciption SUBSCRIPTION_ID` where SUBSCRIPTION_ID is the value of the `id` field.

- Copy the example Terraform Vars file and make any required changes: `cp terraform/example-terraform.tfvars terraform/terraform.tfvars`

### Run the script
Available commands are:
- `./jumpbox-infra.sh apply`
- `./jumpbox_infra.sh destroy`
- `./jumpbox_infra.sh output`
