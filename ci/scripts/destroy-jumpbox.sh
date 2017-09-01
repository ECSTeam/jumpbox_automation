#!/bin/bash

set -ex

root_dir=$PWD

cd $IAAS_DIRECTORY/terraform
# Have to run terraform init again since each task runs in a new docker container
terraform init

cp $root_dir/jumpbox-artifacts/terraform.tfstate .
cp $root_dir/jumpbox-artifacts/terraform-final.tfvars .

cd $IAAS_DIRECTORY
./jumpbox_infra.sh $JUMPBOX_ACTION
