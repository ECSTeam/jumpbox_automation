#!/bin/bash

# Pull variables from vault

aws configure<<EOF 1>/dev/null
$AWS_ACCESS_KEY
$AWS_SECRET_ACCESS_KEY
$AWS_REGION
json
EOF

export TF_VAR_aws_access_key=$AWS_ACCESS_KEY
export TF_VAR_aws_secret_key=$AWS_SECRET_ACCESS_KEY
