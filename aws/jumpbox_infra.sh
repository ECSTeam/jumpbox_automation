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
##################################################

#set -x 

function usage () {
  cat <<EOF
USAGE:
   apply    			Create IaaS resources and Jumpbox
	-p <prefix>			Prefix to use for Terraform Resources
	-r <aws_region>			AWS Region for the Jumpbox
	-z <aws_availability_zone>	AWS Availability Zone where the Jumpbox will be deployed
        -k <aws_key_name>               AWS SSH Key Name to be generated an uploaded to AWS
	-a <aws_role_arn>		AWS ARN for the IAM Role that terraform will assume
        -u <jumpbox_users>		Comma delimited list of users to add to the Jumpbox

   verify   			Verify connection to the Jumpbox after creation

   ssh      			SSH into the Jumpbox

   destroy  			Destroy all Terraform Resources that were created
EOF
}

function get_opts () {

  local OPTIND
  OPTIND=2

  TF_VAR_prefix=""
  TF_VAR_aws_region=""
  TF_VAR_az1=""
  TF_VAR_aws_key_name=""
  TF_VAR_aws_role_arn=""
  TF_VAR_jumpbox_users=""

  # Parse the command argument list
  while getopts hp:r:z:k:a:u: opt; do
    case $opt in
      h|\?)
          usage
          exit 0
          ;;
      p)
          export TF_VAR_prefix=$OPTARG
          ;;
      r) 
          export TF_VAR_aws_region=$OPTARG
          ;;
      z)
          export TF_VAR_az1=$OPTARG
          ;;
      k)
          export TF_VAR_aws_key_name=$OPTARG
          ;;
      a)
          export TF_VAR_aws_role_arn=$OPTARG
          ;;
      u)
          export TF_VAR_jumpbox_users=$OPTARG
          ;;
      *)
          echo "Unknown argument - $opt"
          usage
          exit 1
          ;;
    esac
  done
  shift $((OPTIND-1))
}

function create_env () {
  AWS_KEY_NAME=$TF_VAR_aws_key_name
  if [[ ! -f $SSH_KEY_DIR/$AWS_KEY_NAME ]]; then
    echo -e " $AWS_KEY_NAME not found. Now generating and uploading to AWS"
    mkdir -p $SSH_KEY_DIR
    ssh-keygen -q -N '' -t rsa -f $SSH_KEY_DIR/$AWS_KEY_NAME
    aws ec2 import-key-pair --key-name $AWS_KEY_NAME --public-key-material file://$SSH_KEY_DIR/$AWS_KEY_NAME.pub
  else
    echo "SSH keypair exists, skipping generation and upload to AWS"
  fi

  terraform init

  cp $TERRAFORM_DIR/terraform.tfvars.example $TERRAFORM_VARS_FILE
  echo "Running terraform apply"

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
    ssh -o StrictHostKeyChecking=no -o BatchMode=yes -i $CWD/../../jumpbox-artifacts/$AWS_KEY_NAME.pem ubuntu@$JUMPBOX_IP pwd
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

CWD=$(pwd)
FILES_DIR=$CWD/files
SSH_KEY_DIR=$CWD/ssh-key
TERRAFORM_DIR=$CWD/terraform
TERRAFORM_VARS_FILE=$TERRAFORM_DIR/terraform-final.tfvars

cd $TERRAFORM_DIR

action=$1

case "$action" in
  -h|--help)
         usage
         exit 0
         ;;
  apply)
         get_opts "$@"
         if [[ -z "$TF_VAR_aws_region" || \
               -z "$TF_VAR_az1" || \
               -z "$TF_VAR_aws_role_arn" || \
               -z "$TF_VAR_aws_key_name" || \
               -z "$TF_VAR_prefix" || \
               -z "$TF_VAR_jumpbox_users" ]];
         then
             echo -e "Missing a required flag\n"
             usage
             exit 1
         fi
         
         create_env
         ;;
  verify)
           verify_env
           ;;
  ssh)
           ssh_env
           ;;
  destroy)
           get_opts "$@"
           destroy_env
           ;;
  *)       echo "Invalid option"
           usage
           ;;
esac
