#!/bin/bash
######################################################
#
# Uses terraform to create and destroy a jumpbox on
# vSphere. 
#
# Requirements:
#  -  Either a setup-env.sh script to set environment
#     variables or those variables must be set in the
#     environment.
#  - ~/.ssh directory must exist. This is required when
#    creating ssh keys.
#
######################################################

set -x 

function setup_env() {
  echo 'Checking for environment setup script in working directory [$CWD]'
  # Source script with username/passwords stuff
  if [ -e setup-env.sh ];
  then
    echo "setup-env.sh exists! Setting up environment..."
    . setup-env.sh
  else
    echo "setup-env.sh does not exist! Attempting to use defaults and/or legacy ENV VARS."
    export TF_VAR_viuser=$VSPHERE_USERNAME
    export TF_VAR_vipassword=$VSPHERE_PASSWORD
    export TF_VAR_viserver=$VSPHERE_SERVER
    export TF_VAR_vidomain=$VSPHERE_DOMAIN
    export TF_VAR_ssh_user=$INIT_VM_USERNAME
    export TF_VAR_ssh_password=$INIT_VM_PASSWORD
    export TF_VAR_ssh_key_path=$SSH_KEY_DIR
    export TF_VAR_vm_client_cert=jumpbox_client
    export TF_VAR_vm_svr_cert=jumpbox_svr
  fi
}

function create_env () {
  # Replace place holders
  cp $TERRAFORM_DIR/terraform.tfvars.example $TERRAFORM_VARS_FILE

  #Create the client key if it does not already exist
  create_client_key

  PWD=$(pwd)
  # Terraform Apply
  echo "Running terraform apply in working directory: $PWD"
  terraform apply -auto-approve -var-file=$TERRAFORM_VARS_FILE
}

function terraform_state_exists () {
  if [[ ! -f $TERRAFORM_DIR/terraform.tfstate ]]; then
    echo "terraform.tfstate file does not exist. Have you created the Jumpbox yet?"
    exit 1
  fi
}

function create_client_key () {
  # Create SSH Key Directory
  if [ ! -d $TF_VAR_ssh_key_path ]; then
    #Creating the ssh_key Directory
    mkdir -p $TF_VAR_ssh_key_path
  fi

  # Create SSH Key Directory
  if [ ! -e $TF_VAR_ssh_key_path/$TF_VAR_vm_client_cert ]; then
    echo 'Creating Jumpbox Client Key...'
    ssh-keygen -t rsa -C jumpbox-clients -f $TF_VAR_ssh_key_path/$TF_VAR_vm_client_cert -q -N ''
  fi
}

function destroy_env () {
  # Destroy terraformed jumpbox env
  echo "Running terraform destroy"
  terraform destroy -var-file=$TERRAFORM_VARS_FILE -force

  # Remove the state files. If present, this would take precedence.
  echo "Deleting $TERRAFORM_DIR/*.tfstate*"
  rm $TERRAFORM_DIR/*.tfstate*

  # Remove terraform vars file
  echo "Removing terraform vars file"
  rm $TERRAFORM_VARS_FILE
}

function verify_env () {
  terraform_state_exists

  JUMPBOX_IP=$(terraform output -state=$TERRAFORM_DIR/terraform.tfstate jumpbox_public_ip)

  RETURN_CODE=1
  SSH_ATTEMPTS=0
  # Ensure the keys have been configured properly.
  until [ $RETURN_CODE == 0 ]; do
    # The pipeline `Create` job outputs artifacts into jumpbox-artifacts which
    # is an input into the `Verify` job. One of those artifacts is the client
    # certificate used for ssh.
    ssh -o StrictHostKeyChecking=no -o BatchMode=yes -i $SSH_KEY_DIR/$TF_VAR_vm_client_cert $TF_VAR_ssh_user@$JUMPBOX_IP pwd
    RETURN_CODE=$(echo -e $?)
    if [[ $RETURN_CODE == 0 ]]; then
      echo -e "\nJumpbox ssh PASSED"
    else
      ((SSH_ATTEMPTS++))
      if [ "$SSH_ATTEMPTS" -gt "5" ]; then
        echo -e "\nJumpbox ssh return code : $RETURN_CODE FAILED"
        exit 1
      fi

      sleep 1
    fi
  done
}

######### BEGIN SCRIPT EXECUTION ###########

#CAPTURE CURRENT DIRECTORY
CWD=$(pwd)
TERRAFORM_DIR=$CWD/terraform
SSH_KEY_DIR=$CWD/ssh-key

#ENSURE VARs are appropriately populated
setup_env

action=$1

if [ -z $action ]; then
  echo "Missing argument. Requires one of {apply|destroy|output}"
  exit 1
fi

#Assumes current directory is the vsphere folder of the jumpbox_automation repo cloned to the filesystem
TERRAFORM_VARS_FILE=$TERRAFORM_DIR/terraform.tfvars

cd $TERRAFORM_DIR

terraform init

if [ $action == output ]; then
  terraform output -state=$TERRAFORM_DIR/terraform.tfstate
elif [ $action == apply ]; then
  create_env
elif [ $action == destroy ]; then
  destroy_env
elif [ $action == verify ]; then
  verify_env
else
  echo "Something went wrong!"
fi
