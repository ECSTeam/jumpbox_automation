#!/bin/bash

set -e

root_dir=$PWD

cd $IAAS_DIRECTORY

cp $root_dir/jumpbox-artifacts/terraform.tfstate terraform/

./jumpbox_infra.sh $JUMPBOX_ACTION
