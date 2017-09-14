#!/bin/bash

# ./set-pipeline.sh lite "./ci/pipeline.yml" "./ci/env/azure-pipeline-params.yml" "./credentials.yml" azure-jumpbox
# ./set-pipeline.sh lite "./ci/pipeline.yml" "./ci/env/aws-pipeline-params.yml" "./credentials.yml" aws-jumpbox
# ./set-pipeline.sh lite "./ci/pipeline.yml" "./ci/env/gcp-pipeline-params.yml" "./credentials.yml" gcp-jumpbox

./set-pipeline.sh lite "./ci/pipeline.yml"      "./ci/env/vsphere-pipeline-params.yml" "./credentials.yml" deploy-vsphere-jumpbox
./set-pipeline.sh lite "./ci/test-pipeline.yml" "./ci/env/vsphere-pipeline-params.yml" "./credentials.yml"   test-vsphere-jumpbox