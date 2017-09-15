# Pre Reqs
- Existing base image in vSphere
    - Download ISO https://www.ubuntu.com/download/server
    - Upload to vSphere
    - Create new VM with ISO attached
    - Setup initial User (Expected: ubuntu) [Can be anything, terraform config needs update if changed]
    - Add new user to sudoers.d
- This image can be any valid VM template. Currently we are staying with a bare ISO install.
- A Snapshot of the VM must be created if `link_clone="true"` in the terraform config

# Manual Deployment
- `cd <repo>/vsphere/terraform`
- Copy `terraform.tfvars.example` to `terraform.tfvars`
- Uncomment and enter valid credential variables: `viuser`, `vipassword`, `ssh-user`, `ssh-password`
- run command `terraform apply`

# Concourse Deployment
- Pipeline types: `ci`, `deploy`
- Pipelines: `<repo>/<pipeline-type>/pipeline.yml`
- Configuration: `<repo>/<pipeline-type>/env/vsphere-pipeline-params.yml`
- Credentials Required: 
    - `scripts-git-username`
    - `scripts-git-password`
    - `iaas-username`
    - `iaas-password`
    - `init-vm-username`
    - `init-vm-password`
- Upload pipeline
    - Edit `<repo>/set-pipelines.sh`
    - Verify `./set-pipeline.sh lite "./<pipeline-type>/pipeline.yml" "./<pipeline-type>/env/vsphere-pipeline-params.yml" "<credentials file location>" <pipeline-type>-vsphere-jumpbox`
    - Run `<repo>/set-pipelines.sh`

# Potential Improvements
- Research Stemcell usage for initial VM image
    - Experiencing Network/Permission releated issues with cloned VMs
