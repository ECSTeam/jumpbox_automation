#!/bin/bash
set -x

function create_env () {
  terraform init

  cp $TERRAFORM_DIR/terraform.tfvars.example $TERRAFORM_VARS_FILE
  echo "aws_access_key        = \"$AWS_ACCESS_KEY\"" >> $TERRAFORM_VARS_FILE
  echo "aws_secret_key        = \"$AWS_SECRET_ACCESS_KEY\"" >> $TERRAFORM_VARS_FILE
  echo "aws_key_name          = \"$AWS_KEY_NAME\"" >> $TERRAFORM_VARS_FILE
  echo "prefix                = \"$AWS_PREFIX\"" >> $TERRAFORM_VARS_FILE
  echo "Running terraform apply"

  mkdir -p $TERRAFORM_DIR/ssh-key

  echo $AWS_PRIVATE_KEY > $TERRAFORM_DIR/ssh-key/gold-environment.pem

  terraform apply -var-file=$TERRAFORM_VARS_FILE

}

function terraform_state_exists () {
  if [[ ! -f $TERRAFORM_DIR/terraform.tfstate ]]; then
    echo "terraform.tfstate file does not exist. Have you created the Jumpbox yet?"
    exit 1
  fi
}

function verify_env () {
  terraform_state_exists

  JUMPBOX_IP=$(terraform output -state=$TERRAFORM_DIR/terraform.tfstate --json | jq -r '.jumpbox_public_ip.value')
  RETURN_CODE=1
  SSH_ATTEMPTS=0
  # Ensure the keys have been configured properly.
  until [ $RETURN_CODE == 0 ]; do
    echo "exit" | telnet $JUMPBOX_IP 22 | grep "Connected"
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
  SSH_KEYNAME=$(cat $TERRAFORM_DIR/terraform.tfvars | grep "aws_key_name" | awk '{print $3}' | tr -d '"')
  ssh -i ~/.ssh/$SSH_KEYNAME.pem -o StrictHostKeyChecking=no ubuntu@$JUMPBOX_IP
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

action=$1

if [ -z $action ]; then
  echo "Missing argument. Requires one of {apply|verify|ssh|destroy}"
  exit 1
fi

CWD=$(pwd)
TERRAFORM_DIR=$CWD/terraform
TERRAFORM_VARS_FILE=$TERRAFORM_DIR/terraform-final.tfvars

cd $TERRAFORM_DIR

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
