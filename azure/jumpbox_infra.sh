#!/bin/bash

set -x 

function create_env () {
  SUBSCRIPTION_ID=$(az account list | jq -r '.[] | select(.isDefault == true) | .id')
  TENANT_ID=$(az account list | jq -r '.[] | select(.isDefault == true) | .tenantId')
  AAD_CLIENT_SECRET=$(cat $TERRAFORM_VARS_FILE | grep -i "client_secret" | awk '{print $3}' | tr -d '"')

  # Create Azure Active Directory app
  echo "Creating Azure AD app"
  az ad app create --display-name "Terraform Jumpbox Service Principle" --password "$AAD_CLIENT_SECRET" --homepage "http://TerraformJumpboxAzureCPI" --identifier-uris "http://TerraformJumpboxAzureCPI"
  APPLICATION_ID=`az ad app list | jq -r '.[] | select(.displayName == "Terraform Jumpbox Service Principle") | .appId'`

  # Create a Service Principle for AAD app
  echo "Creating a Service Principle for AAD app" 
  az ad sp create --id $APPLICATION_ID

  # Assign the Contributor role to the Service Principle
  # Loop through until the role is assigned successfully. May take a few tries.
  echo "Assigning Contributor role to the Service Principle"
  az role assignment create --assignee "$APPLICATION_ID" --role "Contributor" --scope /subscriptions/$SUBSCRIPTION_ID
  RETURN_CODE=$?
  until [ "$RETURN_CODE" -eq "0" ]; do
    echo "Assigning Contributor failed. Retrying in 5 seconds."
    sleep 5
    az role assignment create --assignee "$APPLICATION_ID" --role "Contributor" --scope /subscriptions/$SUBSCRIPTION_ID
    RETURN_CODE=$?
  done

  # Create Jumpbox SSH Keypair
  ssh-keygen -q -N '' -t rsa -f ~/.ssh/azure-jumpbox -C ubuntu
  JUMPBOX_PUBLIC_KEY=$(cat ~/.ssh/azure-jumpbox.pub)

  # Replace place holders
  cp $TERRAFORM_DIR/terraform.tfvars $TERRAFORM_VARS_FILE
  echo "subscription_id                   = \"$SUBSCRIPTION_ID\"" >> $TERRAFORM_VARS_FILE
  echo "tenant_id                         = \"$TENANT_ID\"" >> $TERRAFORM_VARS_FILE
  echo "client_id                         = \"$APPLICATION_ID\"" >> $TERRAFORM_VARS_FILE
  echo "vm_admin_public_key               = \"$JUMPBOX_PUBLIC_KEY\"" >> $TERRAFORM_VARS_FILE

  # Terraform Apply
  echo "Running terraform plan"
  terraform plan -var-file=$TERRAFORM_VARS_FILE
  RETURN_CODE=$?
  until [ $RETURN_CODE -eq "0" ]; do
    echo "Contributor role not applied yet. Retrying!"
    sleep 5
    terraform plan -var-file=$TERRAFORM_VARS_FILE
    RETURN_CODE=$?
  done
  terraform apply -var-file=$TERRAFORM_VARS_FILE
}

function destroy_env () {
  # Destroy terraformed jumpbox env 
  echo "Running terraform destroy"
  terraform destroy -var-file=$TERRAFORM_VARS_FILE -force
  RETURN_CODE=$?
  until [ $RETURN_CODE -eq "0" ]; do
    echo "Destroy errored. Retrying!"
    sleep 5
    terraform destroy -var-file=$TERRAFORM_VARS_FILE -force
    RETURN_CODE=$?
  done

  # Delete Azure Active Directory app and Service Principle
  echo "Deleting Azure AD app and Service Principle"
  az ad app delete --id $(az ad app list | jq -r '.[] | select(.displayName == "Terraform Jumpbox Service Principle") | .appId') 

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

if [ $action == output ]; then
  terraform output -state=$TERRAFORM_DIR/terraform.tfstate
elif [ $action == apply ]; then
  create_env
elif [ $action == destroy ]; then
  destroy_env
else
  echo "Something went wrong!"  
fi
