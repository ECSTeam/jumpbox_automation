#!/bin/bash

# Pull variables from vault

aws configure<<EOF 1>/dev/null
$AWS_ACCESS_KEY
$AWS_SECRET_ACCESS_KEY
$AWS_REGION
json
EOF
