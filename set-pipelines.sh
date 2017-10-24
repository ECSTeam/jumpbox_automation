#!/bin/bash

### Continuous Integration ###
./set-pipeline.sh gold "./ci/pipeline.yml" "./ci/env/azure-pipeline-params.yml" azure-jumpbox
./set-pipeline.sh gold "./ci/pipeline.yml" "./ci/env/aws-pipeline-params.yml" aws-jumpbox
./set-pipeline.sh gold "./ci/pipeline.yml" "./ci/env/gcp-pipeline-params.yml" gcp-jumpbox
./set-pipeline.sh gold "./ci/pipeline.yml" "./ci/env/vsphere-pipeline-params.yml" vsphere-jumpbox

### Deployments ###
#./set-pipeline.sh lite "./deploy/pipeline.yml" "./deploy/env/vsphere-pipeline-params.yml" deploy-vsphere-jumpbox
