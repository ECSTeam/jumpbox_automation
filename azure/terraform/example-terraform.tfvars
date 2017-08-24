# Replace below values if needed
env_name                          = "oss-bosh-jumpbox" # Environment prefix for created resources
location                          = "westus"           # Azure region to create the Resource Group
azure_terraform_vnet_cidr         = "172.28.1.0/24"    # Network CIDR range
azure_terraform_subnet_infra_cidr = "172.28.1.0/26"    # Valid CIDR range within the overall network CIDR
jumpbox_vm_size                   = "Standard_DS1_v2"  # Azure Image type for the Jumpbox Server
jumpbox_private_ip                = "172.28.1.10"      # Assign a static IP to the Jumpbox Server
vm_admin_username                 = "ubuntu"           # Default VM user
vm_admin_password                 = "welcome1"         # Required by terraform, can be anything
client_secret                     = "A[jumpbox]Z"      # Client Secret for the Azure AD Service Principle


# DO NOT EDIT. The create-jumpbox-env script will populate
subscription_id                   = "AZURE_SUBSCRIPTION_ID"
tenant_id                         = "AZURE_TENANT_ID"
client_id                         = "AZURE_ACTIVE_DIRECTORY_APPLICATION_ID"
vm_admin_public_key               = "SSH_PUBLIC_KEY_CONTENTS"
