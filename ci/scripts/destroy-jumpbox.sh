#!/bin/bash

set -e

export ROOT_DIR=$PWD

cd $IAAS_DIRECTORY/terraform
# Have to run terraform init again since each task runs in a new docker container
terraform init

cp $ROOT_DIR/jumpbox-artifacts/terraform.tfstate .
cp $ROOT_DIR/jumpbox-artifacts/terraform-final.tfvars .

cd $ROOT_DIR/$IAAS_DIRECTORY
./jumpbox_infra.sh $JUMPBOX_ACTION
