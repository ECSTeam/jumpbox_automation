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
  if [[ ! -f $TERRAFORM_VARS_FILE ]]; then
    echo -e "\nterraform.tfvars does not exist.\nSee the prereqs in the README.md\n"
    exit 1
  fi

  PROJECT_ID=$(gcloud config list --format json | jq -r '.core.project')
  IAM_SERVICE_ACCOUNT_NAME=$(cat $TERRAFORM_VARS_FILE | grep "env_name" | awk '{print $3}' | tr -d '"')
  IAM_SERVICE_ACCOUNT_EMAIL=$(gcloud iam service-accounts list --format json | jq -r '.[] | select(.displayName == "'$IAM_SERVICE_ACCOUNT_NAME'") .email')

  if [[ -z $IAM_SERVICE_ACCOUNT_EMAIL ]]; then
    gcloud iam service-accounts create $IAM_SERVICE_ACCOUNT_NAME --display-name $IAM_SERVICE_ACCOUNT_NAME
    IAM_SERVICE_ACCOUNT_EMAIL=$(gcloud iam service-accounts list --format json | jq -r '.[] | select(.displayName == "'$IAM_SERVICE_ACCOUNT_NAME'") .email')
    gcloud iam service-accounts keys create "terraform.key.json" --iam-account $IAM_SERVICE_ACCOUNT_EMAIL
    gcloud projects add-iam-policy-binding $PROJECT_ID --role roles/editor --member serviceAccount:$IAM_SERVICE_ACCOUNT_EMAIL
  else
    echo "Service account $IAM_SERVICE_ACCOUNT_EMAIL already exists"
  fi

  terraform init

  # Terraform Apply
  echo "Running terraform apply"
  export TF_VAR_credentials_file=$TERRAFORM_DIR/terraform.key.json
  terraform apply -var-file=$TERRAFORM_VARS_FILE -auto-approve

  mkdir -p $SSH_KEY_DIR
  terraform output -state=$TERRAFORM_DIR/terraform.tfstate ssh_private_key > $SSH_KEY_DIR/key
  chmod 0400 $SSH_KEY_DIR/key
}

function terraform_state_exists () {
  if [[ ! -f $TERRAFORM_DIR/terraform.tfstate ]]; then
    echo "terraform.tfstate file does not exist. Have you created the Jumpbox yet?"
    exit 1
  fi
}

function destroy_env () {
  export TF_VAR_credentials_file=$TERRAFORM_DIR/terraform.key.json

  # Destroy terraformed jumpbox env
  echo "Running terraform destroy"
  terraform destroy -var-file=$TERRAFORM_VARS_FILE -force

  # Delete the GCP IAM Service Account
  PROJECT_ID=$(gcloud config list --format json | jq -r '.core.project')
  IAM_SERVICE_ACCOUNT_NAME=$(cat $TERRAFORM_VARS_FILE | grep "env_name" | awk '{print $3}' | tr -d '"')
  IAM_SERVICE_ACCOUNT_EMAIL=$(gcloud iam service-accounts list --format json | jq -r '.[] | select(.displayName == "'$IAM_SERVICE_ACCOUNT_NAME'") .email')
  echo "Deleting the service account user"
  gcloud projects remove-iam-policy-binding $PROJECT_ID --role roles/editor --member serviceAccount:$IAM_SERVICE_ACCOUNT_EMAIL
  gcloud -q iam service-accounts delete $IAM_SERVICE_ACCOUNT_EMAIL

  # Remove the state files. If present, this would take precedence.
  echo "Deleting $TERRAFORM_DIR/*.tfstate*"
  rm $TERRAFORM_DIR/*.tfstate*

  # Remove GCP IAM service account credentials file
  echo "Removing $TERRAFORM_DIR/terraform.key.json"
  rm $TERRAFORM_DIR/terraform.key.json

  # Remove SSH_KEY_DIR
  echo "Removing $SSH_KEY_DIR"
  rm -rf $SSH_KEY_DIR
}

function verify_env () {
  terraform_state_exists

  JUMPBOX_IP=$(terraform output -state=$TERRAFORM_DIR/terraform.tfstate jumpbox_public_ip)

  RETURN_CODE=1
  SSH_ATTEMPTS=0
  # Ensure the keys have been configured properly.
  until [ $RETURN_CODE == 0 ]; do
    ssh -o StrictHostKeyChecking=no -o BatchMode=yes -i $SSH_KEY_DIR/key ubuntu@$JUMPBOX_IP pwd
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

function ssh_env {
  terraform_state_exists

  JUMPBOX_IP=$(terraform output -state=$TERRAFORM_DIR/terraform.tfstate jumpbox_public_ip)
  ssh -i $SSH_KEY_DIR/key -o StrictHostKeyChecking=no ubuntu@$JUMPBOX_IP
}

CWD=$(pwd)
SSH_KEY_DIR=$CWD/ssh-key
TERRAFORM_DIR=$CWD/terraform
TERRAFORM_VARS_FILE=$TERRAFORM_DIR/terraform.tfvars

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
