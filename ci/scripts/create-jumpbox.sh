#!/bin/bash

set -ex

root_dir=$PWD

cd $IAAS_DIRECTORY

cp terraform/terraform.tfvars.example terraform/terraform.tfvars

./jumpbox_infra.sh $JUMPBOX_ACTION

cp terraform/terraform.tfstate $root_dir/jumpbox-artifacts/
cp terraform/terraform-final.tfvars $root_dir/jumpbox-artifacts/
