#!/bin/bash

set -e

export ROOT_DIR=$PWD

cd $IAAS_DIRECTORY

cp $ROOT_DIR/jumpbox-artifacts/terraform.tfstate terraform/
cp $ROOT_DIR/jumpbox-artifacts/terraform.tfvars terraform/

if [[ ! -d $ROOT_DIR/$IAAS_DIRECTORY/ssh-key ]]; then
  cp -R $ROOT_DIR/jumpbox-artifacts/ssh-key/ $ROOT_DIR/$IAAS_DIRECTORY/ssh-key/
fi

./jumpbox_infra.sh $JUMPBOX_ACTION
