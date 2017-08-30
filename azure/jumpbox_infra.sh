#!/bin/bash

function create_env () {
  # Set account level environment variables
  SUBSCRIPTION_ID=$(az account list | jq -r '.[] | select(.isDefault == true) | .id')
  TENANT_ID=$(az account list | jq -r '.[] | select(.isDefault == true) | .tenantId')

  # Create Service Principle and assign Contributor role
  echo "Creating service principle and assigning contributor role."
  JUMPBOX_IDENTITY_AD=$(az ad sp create-for-rbac --name "http://TerraformJumpboxAzureCPI" --role="Contributor" --scopes="/subscriptions/$SUBSCRIPTION_ID" | jq -r '.| "\(.appId):\(.password)"')
  APPLICATION_ID=$(echo $JUMPBOX_IDENTITY_AD | cut -d ':' -f1)
  CLIENT_SECRET=$(echo $JUMPBOX_IDENTITY_AD | cut -d ':' -f2)

  # Create Jumpbox SSH Keypair
  ssh-keygen -q -N '' -t rsa -f ~/.ssh/azure-jumpbox -C ubuntu
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
  echo "Missing argument. Requires one of {apply|destroy|output}"
  exit 1
fi

CWD=$(pwd)
TERRAFORM_DIR=$CWD/terraform
TERRAFORM_VARS_FILE=$TERRAFORM_DIR/terraform-final.tfvars

cd $TERRAFORM_DIR

az login -u $IAAS_USERNAME -p $IAAS_PASSWORD

if [ $action == output ]; then
  terraform output -state=$TERRAFORM_DIR/terraform.tfstate
elif [ $action == apply ]; then
  create_env
elif [ $action == destroy ]; then
  destroy_env
else
  echo "Something went wrong!"  
fi