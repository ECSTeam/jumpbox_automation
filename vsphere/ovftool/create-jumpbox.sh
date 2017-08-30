#!/bin/bash
set -ex

############# REMOVE After testing
VCENTER_USER="lab09admin@lab.ecsteam.local"
VCENTER_PASSWORD="Ecsl@b99"
IAAS="vSphere"
NETWORK_NAME="Lab09-NetA"
DATA_STORE_NAME="nfs-lab09-vol1"
# OPSMAN_IP=""
# OPSMAN_NETMASK=""
# OPSMAN_GATEWAY=""
# OPSMAN_DNS=""
# OPSMAN_NTP=""
# OPSMAN_VM_PASS=""

TEMP_LOCATION="C:/Users/edgar.coles/downloads"
VCENTER_HOST="ecsdenlabvc01.lab.ecsteam.local"
DATACENTER_NAME="Lab09-Datacenter01"
CLUSTER_NAME="Lab09-Cluster01"

echo "=============================================================================================="
echo "Deploying vSphere jumpbox ..."
echo "=============================================================================================="

echo "=============================================================================================="
echo "Executing ovf command ...."
vcenter_user=${VCENTER_USER//\\/%5c}
vcenter_user=${vcenter_user/@/%40}
vcenter_pass=${VCENTER_PASSWORD//\\/%5c}
vcenter_pass=${vcenter_pass/@/%40}

if [[ $IAAS == "vSphere" ]]; then
    ops_manager_file_name=$(ls $TEMP_LOCATION/*.ovf)
fi

ovf_cmd="ovftool --name='Jumpbox' \
        -nw=$NETWORK_NAME \
        -ds=$DATA_STORE_NAME \
        -dm=thin \
        --powerOn \
        --noSSLVerify \
        --acceptAllEulas \
        --sourceType=ovf \
    $ops_manager_file_name \
    vi://$vcenter_user:$vcenter_pass@$VCENTER_HOST/$DATACENTER_NAME/host/$CLUSTER_NAME"
echo $ovf_cmd
eval $ovf_cmd

echo "=============================================================================================="
