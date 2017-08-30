#!/bin/bash

set -ex

root_dir=$PWD

cd $IAAS_DIRECTORY

# az login -u $IAAS_USERNAME -p $IAAS_PASSWORD

ls -la

./jumpbox_infra.sh $JUMPBOX_ACTION

./jumpbox_infra.sh output jumpbox_public_ip >> $root_dir/jumpbox-keys/ip_address.txt
