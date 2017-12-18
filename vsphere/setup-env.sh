#!/bin/bash

#These are defined here so they can be used by both the shell and terraform!
export TF_VAR_viuser=<CHANGE ME>
export TF_VAR_vipassword=<CHANGE ME>
export TF_VAR_viserver=ecsdenlabvc01.lab.ecsteam.local
export TF_VAR_vidomain=lab.ecsteam.local
export TF_VAR_ssh_user=ubuntu
export TF_VAR_ssh_password=<CHANGE ME>
export TF_VAR_ssh_key_path=./ssh-key/
export TF_VAR_vm_client_cert=jumpbox_client
export TF_VAR_vm_svr_cert=jumpbox_svr


#This code is so that any legacy code using different variables will continue to work.
if [[ $VSPHERE_USERNAME != '' ]];then
  echo Setting vsphere login username to [$VSPHERE_USERNAME]
  TF_VAR_viuser=$VSPHERE_USERNAME
fi

if [[ $VSPHERE_PASSWORD != '' ]];then
  TF_VAR_vipassword=$VSPHERE_PASSWORD
fi

if [[ $VSPHERE_SERVER != '' ]];then
  TF_VAR_viserver=$VSPHERE_SERVER
fi

if [[ $VSPHERE_DOMAIN != '' ]];then
  TF_VAR_vidomain=$VSPHERE_DOMAIN
fi

if [[ $INIT_VM_USERNAME != '' ]];then
  TF_VAR_ssh_user=$INIT_VM_USERNAME
fi

if [[ $INIT_VM_PASSWORD != '' ]];then
  TF_VAR_ssh_password=$INIT_VM_PASSWORD
fi
