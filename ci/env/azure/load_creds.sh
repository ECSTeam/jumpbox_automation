#!/bin/bash

# Pull variables from vault

az cloud set --name AzureCloud
az login -u $AZURE_USERNAME -p $AZURE_PASSWORD

export TF_VAR_vm_admin_username=$INIT_VM_USERNAME
export TF_VAR_vm_admin_password=$INIT_VM_PASSWORD
