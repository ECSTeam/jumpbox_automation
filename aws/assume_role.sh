#!/bin/bash

# Will need this for Concourse container

### Grab values from VAULT
# ACCESS_KEY
# SECRET_ACCESS_KEY
# REGION
# OUTPUT
# ROLE_ARN

aws configure<<EOF 1>/dev/null
$ACCESS_KEY
$SECRET_ACCESS_KEY
$REGION
$OUTPUT
EOF

rm ~/.aws/config

cat <<EOF > ~/.aws/config
[default]
output = json
region = us-east-1

[profile terraform]
role_arn = $ROLE_ARN
source_profile = default
region = us-east-1
output = json
EOF
