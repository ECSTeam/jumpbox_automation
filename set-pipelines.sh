#!/bin/bash

### Continuous Integration ###
./set-pipeline.sh gold "./ci/pipeline.yml" "./ci/env/azure-pipeline-params.yml" "./credentials.yml" azure-jumpbox
./set-pipeline.sh gold "./ci/pipeline.yml" "./ci/env/aws-pipeline-params.yml" "./credentials.yml" aws-jumpbox
./set-pipeline.sh gold "./ci/pipeline.yml" "./ci/env/gcp-pipeline-params.yml" "./credentials.yml" gcp-jumpbox
./set-pipeline.sh gold "./ci/pipeline.yml" "./ci/env/vsphere-pipeline-params.yml" "./credentials.yml"   vsphere-jumpbox

### Deployments ###
#./set-pipeline.sh lite "./deploy/pipeline.yml" "./deploy/env/vsphere-pipeline-params.yml" "./credentials.yml" deploy-vsphere-jumpbox
