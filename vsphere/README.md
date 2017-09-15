# Pre Reqs
- Existing base image in Vsphere
    - Download ISO https://www.ubuntu.com/download/server
    - Setup initial User (Default: ubuntu)
    - Add new user to sudoers.d
- This image can be any valid VM template. Currently we are staying with a bare ISO install

# Manual Deployment
- `cd <repo>/vsphere/terraform`
- Copy `terraform.tfvars.example` to `terraform.tfvars`
- Uncomment and enter valid credential variables: `viuser`, `vipassword`, `ssh-user`, `ssh-password`
- run command `terraform apply`

# Concourse Deployment
- Pipeline: `<repo>/ci/pipeline.yml`
- Configuration: `<repo>/ci/env/vsphere-pipeline-params.yml`
- Credentials Required: 
    - `scripts-git-username`
    - `scripts-git-password`
    - `iaas-username`
    - `iaas-password`
    - `init-vm-username`
    - `init-vm-password`
- Upload pipeline
    - Edit `<repo>/set-pipelines.sh`
    - Verify `./set-pipeline.sh lite "./ci/pipeline.yml" "./ci/env/vsphere-pipeline-params.yml" "<credentials file location>" deploy-vsphere-jumpbox`
    - Run `<repo>/set-pipelines.sh`

# Potential Improvements
- Research Stemcell usage for initial VM image
    - Experiencing Network/Permission releated issues with cloned VMs