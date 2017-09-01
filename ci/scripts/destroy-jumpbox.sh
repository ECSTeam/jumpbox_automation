#!/bin/bash

set -ex

root_dir=$PWD

cd $IAAS_DIRECTORY

cp $root_dir/jumpbox-artifacts/terraform.tfstate terraform/
cp $root_dir/jumpbox-artifacts/terraform-final.tfvars terraform/

./jumpbox_infra.sh $JUMPBOX_ACTION
