#!/bin/bash

function create_env () {
  # Replace place holders
  cp $TERRAFORM_DIR/terraform.tfvars.example $TERRAFORM_VARS_FILE

  echo "viuser=\"$IAAS_USERNAME\"" >> $TERRAFORM_VARS_FILE
  echo "vipassword=\"$IAAS_PASSWORD\"" >> $TERRAFORM_VARS_FILE

  echo "ssh-user=\"$INIT_VM_USERNAME\"" >> $TERRAFORM_VARS_FILE
  echo "ssh-password=\"$INIT_VM_PASSWORD\"" >> $TERRAFORM_VARS_FILE

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

function destroy_env () {
  # Destroy terraformed jumpbox env 
  echo "Running terraform destroy"
  terraform destroy -var-file=$TERRAFORM_VARS_FILE -force

  # Remove the state files. If present, this would take precedence. 
  echo "Deleting $TERRAFORM_DIR/*.tfstate*"
  rm $TERRAFORM_DIR/*.tfstate*

  # Remove terraform vars final
  echo "Removing terraform vars final"
  rm $TERRAFORM_VARS_FILE
}

function verify_env () {
  terraform_state_exists

  JUMPBOX_IP=$(terraform output -state=$TERRAFORM_DIR/terraform.tfstate jumpbox_public_ip)

  # use netcat to check connectivity
  nc -z $JUMPBOX_IP 22
  RETURN_CODE=$(echo -e $?)
  if [[ $RETURN_CODE == 0 ]]; then
    echo -e "\nJumpbox network ping PASSED"
  else
    echo -e "\nJumpbox network ping FAILED"
    exit 1
  fi

  pwd; ls
  
  # Ensure the keys have been configured properly.
  ssh -o BatchMode=yes -i ../jumpbox-artifacts/ssh-key/jumpbox_rsa ubuntu@$JUMPBOX_IP pwd
  RETURN_CODE=$(echo -e $?)
  if [[ $RETURN_CODE == 0 ]]; then
    echo -e "\nJumpbox ssh PASSED"
  else
    echo -e "\nJumpbox ssh FAILED"
    exit 1
  fi
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
