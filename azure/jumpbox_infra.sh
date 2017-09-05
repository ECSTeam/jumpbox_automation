#!/bin/bash

function create_env () {
  terraform init
  # Set account level environment variables
  SUBSCRIPTION_ID=$(az account list | jq -r '.[] | select(.isDefault == true) | .id')
  TENANT_ID=$(az account list | jq -r '.[] | select(.isDefault == true) | .tenantId')

  # Create Service Principle and assign Contributor role
  echo "Creating service principal and assigning contributor role."
  JUMPBOX_IDENTITY_AD=$(az ad sp create-for-rbac --name "http://TerraformJumpboxAzureCPI" --role="Contributor" --scopes="/subscriptions/$SUBSCRIPTION_ID" | jq -r '.| "\(.appId):\(.password)"')
  APPLICATION_ID=$(echo $JUMPBOX_IDENTITY_AD | cut -d ':' -f1)
  CLIENT_SECRET=$(echo $JUMPBOX_IDENTITY_AD | cut -d ':' -f2)

  # Create Jumpbox SSH Keypair
  if [[ ! -d "$HOME/.ssh" ]]; then
    mkdir ~/.ssh
  fi
  ssh-keygen -q -N '' -t rsa -f ~/.ssh/azure-jumpbox
  JUMPBOX_PUBLIC_KEY=$(cat ~/.ssh/azure-jumpbox.pub)

  # Replace place holders
  cp $TERRAFORM_DIR/terraform.tfvars $TERRAFORM_VARS_FILE
  echo "subscription_id                   = \"$SUBSCRIPTION_ID\"" >> $TERRAFORM_VARS_FILE
  echo "tenant_id                         = \"$TENANT_ID\"" >> $TERRAFORM_VARS_FILE
  echo "client_id                         = \"$APPLICATION_ID\"" >> $TERRAFORM_VARS_FILE
  echo "client_secret                     = \"$CLIENT_SECRET\"" >> $TERRAFORM_VARS_FILE
  echo "vm_admin_public_key               = \"$JUMPBOX_PUBLIC_KEY\"" >> $TERRAFORM_VARS_FILE

  # Terraform Apply
  echo "Running terraform apply"
  terraform apply -var-file=$TERRAFORM_VARS_FILE
}

function terraform_state_exists () {
  if [[ ! -f $TERRAFORM_DIR/terraform.tfstate ]]; then
    echo "terraform.tfstate file does not exist. Have you created the Jumpbox yet?"
    exit 1
  fi
}

function ssh_env () {
  terraform_state_exists  

  JUMPBOX_IP=$(terraform output -state=$TERRAFORM_DIR/terraform.tfstate --json | jq -r '.jumpbox_public_ip.value')
  VM_USER=$(cat $TERRAFORM_VARS_FILE | grep "vm_admin_username" | awk '{print $3}' | tr -d '"')
  ssh -i ~/.ssh/azure-jumpbox -o StrictHostKeyChecking=no $VM_USER@$JUMPBOX_IP
}

function verify_env () {
  terraform_state_exists

  JUMPBOX_IP=$(terraform output -state=$TERRAFORM_DIR/terraform.tfstate --json | jq -r '.jumpbox_public_ip.value')
  echo "exit" | telnet $JUMPBOX_IP 22 | grep "Connected"
  RETURN_CODE=$(echo -e $?)
  if [[ $RETURN_CODE == 0 ]]; then
    echo -e "\nJumpbox is UP!"
  else
    echo -e "\nJumpbox is DOWN!"
    exit 1
  fi
}

function destroy_env () {
  # Destroy terraformed jumpbox env 
  echo "Running terraform destroy"
  terraform destroy -var-file=$TERRAFORM_VARS_FILE -force

  # Delete Azure Active Directory app and Service Principle
  echo "Deleting Azure AD app and Service Principle"
  az ad app delete --id $(cat $TERRAFORM_VARS_FILE | grep "client_id" | awk '{print $3}' | tr -d '"')

  # Remove the state files. If present, this would take precedence. 
  echo "Deleting $TERRAFORM_DIR/*.tfstate*"
  rm $TERRAFORM_DIR/*.tfstate*

  # Cleanup Jumpbox SSH keys
  echo "Removing Jumpbox Key Pair"
  rm ~/.ssh/azure-jumpbox*

  # Remove terraform vars final
  echo "Removing terraform vars final"
  rm $TERRAFORM_VARS_FILE
}

action=$1

if [ -z $action ]; then
  echo "Missing argument. Requires one of {apply|ssh|verify|destroy}"
  exit 1
fi

CWD=$(pwd)
TERRAFORM_DIR=$CWD/terraform
TERRAFORM_VARS_FILE=$TERRAFORM_DIR/terraform-final.tfvars

cd $TERRAFORM_DIR

az login -u $IAAS_USERNAME -p $IAAS_PASSWORD 1> /dev/null

if [ $action == "apply" ]; then
  create_env
elif [ $action == "verify" ]; then
  verify_env
elif [ $action == "ssh" ]; then
  ssh_env
elif [ $action == "destroy" ]; then
  destroy_env
else
  echo "Something went wrong!"  
fi
