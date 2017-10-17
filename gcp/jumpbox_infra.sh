#!/bin/bash

set -x

function create_env () {

  # Replace place holders
  cp $TERRAFORM_DIR/terraform.tfvars.example $TERRAFORM_VARS_FILE
  
  CREDS_PRIVATE_KEY=$(echo $CREDS_PRIVATE_KEY | tr '\n' ' ')
  cat <<EOF >> ./credentials.json
  {
    "type": "$CREDS_TYPE",
    "project_id": "$CREDS_PROJECT_ID",
    "private_key_id": "$CREDS_PRIVATE_KEY_ID",
    "private_key": "$CREDS_PRIVATE_KEY",
    "client_email": "$CREDS_EMAIL",
    "client_id": "$CREDS_CLIENT_ID",
    "client_x509_cert_url": "$CREDS_CERT_URL",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://accounts.google.com/o/oauth2/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs"
    }  
EOF

  cp ./credentials.json ./jumpbox-artifacts

  # Terraform Apply
  echo "Running terraform apply"
  terraform apply -var-file=$TERRAFORM_VARS_FILE

  PRIVATE_KEY=$(terraform output -state=$TERRAFORM_DIR/terraform.tfstate ssh_private_key)

  mkdir -p ssh-key 
  echo $PRIVATE_KEY ssh-key/key
  chmod 0400 ssh-key/key
}

function terraform_state_exists () {
  if [[ ! -f $TERRAFORM_DIR/terraform.tfstate ]]; then
    echo "terraform.tfstate file does not exist. Have you created the Jumpbox yet?"
    exit 1
  fi
}

function destroy_env () {

  cat <<EOF >> ./credentials.json
  {
    "type": "$CREDS_TYPE",
    "project_id": "$CREDS_PROJECT_ID",
    "private_key_id": "$CREDS_PRIVATE_KEY_ID",
    "private_key": "$CREDS_PRIVATE_KEY",
    "client_email": "$CREDS_EMAIL",
    "client_id": "$CREDS_CLIENT_ID",
    "client_x509_cert_url": "$CREDS_CERT_URL",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://accounts.google.com/o/oauth2/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs"
    }  
EOF

  #exit 1

  #echo "Running terraform init"
  #terraform init
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
  
  JUMPBOX_IP=$(terraform output -state=$TERRAFORM_DIR/terraform.tfstate ops_manager_public_ip)

  RETURN_CODE=1
  SSH_ATTEMPTS=0
  # Ensure the keys have been configured properly.
  until [ $RETURN_CODE == 0 ]; do
    ssh -o StrictHostKeyChecking=no -o BatchMode=yes -i ../../../jumpbox-artifacts/key ubuntu@$JUMPBOX_IP pwd
    RETURN_CODE=$(echo -e $?)
    if [[ $RETURN_CODE == 0 ]]; then
      echo -e "\nJumpbox ssh PASSED"
    else
      ((SSH_ATTEMPTS++))
      if [ $SSH_ATTEMPTS > 5 ]; then 
        echo -e "\nJumpbox ssh return code : $RETURN_CODE FAILED"
        exit 1
      fi

      sleep 1
    fi
  done
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
