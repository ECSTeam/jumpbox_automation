#!/bin/bash

set -ex

cd $IAAS_DIRECTORY

# az login -u $IAAS_USERNAME -p $IAAS_PASSWORD

ls -la

./jumpbox_infra.sh $JUMPBOX_ACTION

./jumpbox_infra.sh output | awk '{print $3}' >> jumpbox-keys/ip_address.txt
