#!/bin/bash

set -ex

cd $IAAS_DIRECTORY

# az login -u $IAAS_USERNAME -p $IAAS_PASSWORD

ls -la

./jumpbox_infra.sh $JUMPBOX_ACTION

./jumpbox_infra.sh output jumpbox_public_ip > jumpbox-keys/ip_address.txt
