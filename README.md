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
  - vi (vim)
  - ssh
  - ssh-keygen
  - sshpass (1.05)
  - terraform (>= v.0.11.1)
