#!/bin/bash

set -e

export ROOT_DIR=$PWD

cd $IAAS_DIRECTORY

cp $ROOT_DIR/jumpbox-artifacts/terraform.tfstate terraform/

./jumpbox_infra.sh $JUMPBOX_ACTION
