#!/bin/bash
################################################################
#
#  Calls the IaaS specific script to create a jumpbox. The 
#  artifacts created during the deployment are then copied to 
#  the `jumpbox-artifacts` output directory for use by other
#  jobs in the pipeline.
#
################################################################


set -e

export ROOT_DIR=$PWD
export IAAS_DIR=$ROOT_DIR/$IAAS_DIRECTORY
export TERRAFORM_DIR=$IAAS_DIR/terraform
export SSH_KEY_PASS=$TERRAFORM_DIR/ssh-key
cd $IAAS_DIR

cp $TERRAFORM_DIR/terraform.tfvars.example $TERRAFORM_DIR/terraform.tfvars

# Create the .ssh for the user. It is needed to 
# perform ssh copy.
mkdir -p ~/.ssh 

./jumpbox_infra.sh $JUMPBOX_ACTION

cp $TERRAFORM_DIR/terraform.tfstate $ROOT_DIR/jumpbox-artifacts/
cp $TERRAFORM_DIR/terraform-final.tfvars $ROOT_DIR/jumpbox-artifacts/
cp $TERRAFORM_DIR/ssh-key/* $ROOT_DIR/jumpbox-artifacts/.
