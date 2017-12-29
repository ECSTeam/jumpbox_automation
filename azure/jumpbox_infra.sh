#!/bin/bash

function usage () {
  cat <<EOF
USAGE:
   apply                Create IaaS resources and Jumpbox
   verify               Verify connection to the Jumpbox after creation
   ssh                  SSH into the Jumpbox
   destroy              Destroy all Terraform Resources that were created
EOF
}

function create_env () {
  terraform init
  # Set account level environment variables
  AZURE_ACCOUNT_METADATA=$(az account list | jq -r '.[] | select(.isDefault == true) | "\(.id):\(.tenantId)"')
  echo $AZURE_ACCOUNT_METADATA > $METADATA_FILE

  # Create Service Principle and assign Contributor role
  echo "Creating service principal and assigning contributor role."
  JUMPBOX_IDENTITY_AD=$(az ad sp create-for-rbac \
    --name "http://TerraformJumpboxAzureCPI" \
    --role="Contributor" \
    --scopes="/subscriptions/$SUBSCRIPTION_ID" \
    | jq -r '.| "\(.appId):\(.password)"')
  echo $JUMPBOX_IDENTITY_AD >> $METADATA_FILE

  # Create Jumpbox SSH Keypair
  if [[ ! -f $SSH_KEY_DIR/$AZURE_KEY_NAME ]]; then
    mkdir -p $SSH_KEY_DIR
    ssh-keygen -q -N '' -t rsa -f $SSH_KEY_DIR/$AZURE_KEY_NAME
  else
    echo "SSH keypair exists, skipping generation"
  fi

  # Create a load vars function. Apply and destroy will need these vars
  export TF_VAR_subscription_id=$(echo $AZURE_ACCOUNT_METADATA | cut -d ':' -f1)
  export TF_VAR_tenant_id=$(echo $AZURE_ACCOUNT_METADATA | cut -d ':' -f2)
  export TF_VAR_client_id=$(echo $JUMPBOX_IDENTITY_AD | cut -d ':' -f1)
  export TF_VAR_client_secret=$(echo $JUMPBOX_IDENTITY_AD | cut -d ':' -f2)
  export TF_VAR_vm_admin_public_key=$(cat $SSH_KEY_DIR/$AZURE_KEY_NAME.pub)
  export TF_VAR_ssh_private_file=$SSH_KEY_DIR/$AZURE_KEY_NAME

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
  ssh -i $SSH_KEY_DIR/$AZURE_KEY_NAME -o StrictHostKeyChecking=no $VM_USER@$JUMPBOX_IP
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
  # Exit for now
  exit 1

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
  # echo "Removing Jumpbox Key Pair"
  # rm $SSH_KEY_DIR/$AZURE_KEY_NAME*

  # Remove terraform vars final
  # echo "Removing terraform vars final"
  # rm $TERRAFORM_VARS_FILE
}

CWD=$(pwd)
SSH_KEY_DIR=$CWD/ssh-key
METADATA_FILE=$CWD/metadata.txt
TERRAFORM_DIR=$CWD/terraform
TERRAFORM_VARS_FILE=$TERRAFORM_DIR/terraform.tfvars
AZURE_KEY_NAME=$(cat $TERRAFORM_VARS_FILE | grep "env_name" | awk '{print $3}' | tr -d '"')


cd $TERRAFORM_DIR

action=$1

# Concourse should login prior to running this script
# az login -u $AZURE_USERNAME -p $AZURE_PASSWORD 1> /dev/null

case "$action" in
  help)
       usage
       exit 0
       ;;
  apply)
       create_env
       ;;
  verify)
       verify_env
       ;;
  ssh)
       ssh_env
       ;;
  destroy)
       destroy_env
       ;;
  *)   echo "Invalid option"
       usage
       exit
       ;;
esac
