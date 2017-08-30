#!/bin/bash

action=$1

if [ -z $action ]; then
  echo "Missing argument. Requires one of {apply|destroy|output}"
  exit 1
fi

CWD=$(pwd)

cd $CWD/terraform

if [ $action == output ]; then
  terraform $action -state=terraform.tfstate
else
  terraform plan -var-file=terraform.tfvars
  terraform $action -var-file=terraform.tfvars
fi
