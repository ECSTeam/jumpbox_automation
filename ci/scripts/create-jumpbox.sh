#!/bin/bash

set -e

ROOT_DIR=$PWD
IAAS_DIR=$ROOT_DIR/$IAAS_DIRECTORY
TERRAFORM_DIR=$IAAS_DIR/terraform
cd $IAAS_DIR

cp $TERRAFORM_DIR/terraform.tfvars.example $TERRAFORM_DIR/terraform.tfvars

# Create the .ssh for the user. It is needed to 
# perform ssh copy.
mkdir -p ~/.ssh 

./jumpbox_infra.sh $JUMPBOX_ACTION

cp $TERRAFORM_DIR/terraform.tfstate $ROOT_DIR/jumpbox-artifacts/
cp $TERRAFORM_DIR/terraform-final.tfvars $ROOT_DIR/jumpbox-artifacts/
cp $TERRAFORM_DIR/ssh-key/* $ROOT_DIR/jumpbox-artifacts/.
