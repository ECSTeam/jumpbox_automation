#!/bin/bash

cd $IAAS_DIRECTORY

jumpbox_infra.sh $JUMPBOX_ACTION

jumpbox_infra.sh output | awk '{print $3}' >> jumpbox-keys/ip_address.txt
