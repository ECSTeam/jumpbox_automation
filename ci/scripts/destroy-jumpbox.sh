#!/bin/bash

set -e

export ROOT_DIR=$PWD
export CONFIG_DIR=$ROOT_DIR/$CONFIG_DIRECTORY
export SSH_KEY_PATH=$ROOT_DIR/jumpbox-artifacts

cd $IAAS_DIRECTORY/terraform
# Have to run terraform init again since each task runs in a new docker container
terraform init

cp $ROOT_DIR/jumpbox-artifacts/terraform.tfstate .
cp $ROOT_DIR/jumpbox-artifacts/terraform.tfvars .

if [[ -f $CONFIG_DIR/load_creds.sh ]]; then
  . $CONFIG_DIR/load_creds.sh
fi

if [[ -f $ROOT_DIR/jumpbox-artifacts/metadata.txt ]]; then
  cp $ROOT_DIR/jumpbox-artifacts/metadata.txt $ROOT_DIR/$IAAS_DIRECTORY
fi

cd $ROOT_DIR/$IAAS_DIRECTORY
./jumpbox_infra.sh $JUMPBOX_ACTION
