# jumpbox_automation #

This repository contains scripts to facilitate the deployment of a Jumpbox (Bastion) server to various IAS providers.

  ##### Currently Supported IAS providers:
    - GCP (Google Cloud Platform)
    - AZURE
    - OPENSTACK
    - vSphere
    - AWS (Amazon Web Services)

To use these scripts change directory to the IAS specific folder and follow the README instructions provided.

## General Prerequisites ##
> Note: Whatever environment you are running the scripts in must have the following)

##### Standard Linux Operating Environment

  1. bash
  2. vi (vim)
  3. ssh
  4. ssh-keygen
  5. sshpass (1.05)
  6. terraform (>= v.0.11.1)

>Note: A docker container has been built that meets all General Prerequisites. If you
don't have access to the repo or want to customize it. The docker file is in the docker folder.
The image is called 'jumpbox-automation'.
