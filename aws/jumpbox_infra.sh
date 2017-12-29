#!/bin/bash

###################################################
#
#  This script creates a jumpbox on AWS. It also
#  provides the ability to verify the jumpbox
#  was created as expected. 
#
#  You can also use this script to delete the
#  jumpbox and ssh to it.
#
###################################################

#set -x 

function usage () {
  cat <<EOF
USAGE:
   apply		Create IaaS resources and Jumpbox
   verify		Verify connection to the Jumpbox after creation
   ssh			SSH into the Jumpbox
   destroy		Destroy all Terraform Resources that were created
EOF
}

function create_env () {
  if [[ ! -f $TERRAFORM_VARS_FILE ]]; then
    echo -e "\nterraform.tfvars does not exist.\nSee the prereqs in the README.md\n"
    exit 1
  fi

  if [[ ! -f $SSH_KEY_DIR/$AWS_KEY_NAME ]]; then
    echo -e "$AWS_KEY_NAME not found. Now generating and uploading to AWS"
    mkdir -p $SSH_KEY_DIR
    aws ec2 create-key-pair --key-name $AWS_KEY_NAME | jq -r '.KeyMaterial' > $SSH_KEY_DIR/$AWS_KEY_NAME
    chmod 0400 $SSH_KEY_DIR/$AWS_KEY_NAME
  else
    echo "SSH keypair exists, skipping generation and upload to AWS"
  fi

  echo "Running terraform apply"
  terraform init
  export TF_VAR_ssh_private_file=$SSH_KEY_DIR/$AWS_KEY_NAME
  terraform apply -var-file=$TERRAFORM_VARS_FILE -auto-approve
}

function terraform_state_exists () {
  if [[ ! -f $TERRAFORM_DIR/terraform.tfstate ]]; then
    echo "terraform.tfstate file does not exist. Have you created the Jumpbox yet?"
    exit 1
  fi
}

################################################################################################
#
#   This function was created to be used by the ci/pipeline.yml verify task. The create task
#   in the pipeline places AWS private key in its output "jumpbox-artifacts". This function
#   uses that key to ssh into the jumpbox, thus verifying it exists.
#
################################################################################################
function verify_env () {
  terraform_state_exists

  JUMPBOX_IP=$(terraform output -state=$TERRAFORM_DIR/terraform.tfstate --json | jq -r '.jumpbox_public_ip.value')
  RETURN_CODE=1
  SSH_ATTEMPTS=0
  # Ensure the keys have been configured properly.
  until [ $RETURN_CODE == 0 ]; do
    # The jumpbox-artifacts are the output of the "create" task in the ci/pipeline.yml. 
    ssh -o StrictHostKeyChecking=no -o BatchMode=yes -i $SSH_KEY_DIR/$AWS_KEY_NAME ubuntu@$JUMPBOX_IP pwd
    RETURN_CODE=$(echo -e $?)
    if [[ $RETURN_CODE == 0 ]]; then
       echo -e "\nJumpbox is UP!"
    else
      ((SSH_ATTEMPTS++))
      if [ "$SSH_ATTEMPTS" -gt "5" ]; then
        echo -e "\nJumpbox is DOWN!"
        exit 1
      fi

      sleep 1
    fi
  done
}

function ssh_env () {
  terraform_state_exists
  JUMPBOX_IP=$(terraform output -state=$TERRAFORM_DIR/terraform.tfstate --json | jq -r '.jumpbox_public_ip.value')
  ssh -i $SSH_KEY_DIR/$AWS_KEY_NAME -o StrictHostKeyChecking=no ubuntu@$JUMPBOX_IP
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

CWD=$(pwd)
SSH_KEY_DIR=$CWD/ssh-key
TERRAFORM_DIR=$CWD/terraform
TERRAFORM_VARS_FILE=$TERRAFORM_DIR/terraform.tfvars
AWS_KEY_NAME=$(cat $TERRAFORM_VARS_FILE | grep "env_name" | awk '{print $3}' | tr -d '"')

cd $TERRAFORM_DIR

action=$1

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
