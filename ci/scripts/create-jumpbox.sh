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
export CONFIG_DIR=$ROOT_DIR/$CONFIG_DIRECTORY
export IAAS_DIR=$ROOT_DIR/$IAAS_DIRECTORY
export TERRAFORM_DIR=$IAAS_DIR/terraform
cd $IAAS_DIR

cp $CONFIG_DIR/terraform.tfvars.example $TERRAFORM_DIR/terraform.tfvars

# Create the .ssh for the user. It is needed to 
# perform ssh copy.
mkdir -p ~/.ssh

if [[ -f $CONFIG_DIR/load_creds.sh ]]; then
  . $CONFIG_DIR/load_creds.sh
fi

./jumpbox_infra.sh $JUMPBOX_ACTION

if [[ -f $IAAS_DIR/metadata.txt ]]; then
  cp $IAAS_DIR/metadata.txt $ROOT_DIR/jumpbox-artifacts/
fi

cp $TERRAFORM_DIR/terraform.tfstate $ROOT_DIR/jumpbox-artifacts/
cp $TERRAFORM_DIR/terraform.tfvars $ROOT_DIR/jumpbox-artifacts/
cp -R $IAAS_DIR/ssh-key/ $ROOT_DIR/jumpbox-artifacts/ssh-key/
