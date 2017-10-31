# Pre Reqs
- Existing base image in vSphere. This image can be any valid VM template. Currently we are staying with a bare ISO install.
    - Download ISO https://www.ubuntu.com/download/server
    - Upload to vSphere
    - Create new VM with ISO attached
      - New Virtual Machine->New Virtual Machine...->Follow Wizard to "Customize hardware"
         - Change "New CD/DVD Drive" to "Datasource ISO File" and select uploaded ISO.
         - Select check box "Connect at power on"
    - Power on VM. This will start the OS installation. Expand the VM console and answer questions accordingly.
      - NOTE: Disk partitioning select "Guided - use entire disk". TODO: Confirm LVM is correct selection.
    - Setup initial User (Expected: ubuntu) [Can be anything, terraform config needs update if changed]
    - If you created a different user, add new user to /etc/sudoers using visudo
    - Turn on ssh - `sudo service ssh start`
    - Disable sudo password entry for the `ubuntu` user
      - `sudo visudo`
      - Add `ubuntu ALL=(ALL) NOPASSWD: ALL` to the bottom of the file.
    - Disable the floppy. (A floppy?!? WTF? Why is this enabled by default?)
      - echo "blacklist floppy" | sudo tee /etc/modprobe.d/blacklist-floppy.conf
      - sudo rmmod floppy
      - sudo update-initramfs -u
    - Take a snapshot of the VM

# Manual Deployment
- `cd <repo>/vsphere/terraform`
- Copy `terraform.tfvars.example` to `terraform.tfvars`
- Uncomment and enter valid credential values: 
    - `viuser`
    - `vipassword`
    - `ssh-user`
    - `ssh-password`
- Review the reset of the attributes and modify according to your environment.
- run command `terraform apply`

# Concourse Deployment
- Pipeline types: `ci`, `deploy`
    - CI: Runs Create and Verify tasks with an ensured Destroy step to clean up
    - Deploy: Runs Create and Verify tasks to setup a VM
- Pipelines: `<repo>/<pipeline-type>/pipeline.yml`
- Configuration: `<repo>/<pipeline-type>/env/vsphere-pipeline-params.yml`
- Copy `<repo>/credentials.yml.stub` to `<repo>/credentials.yml`
- Enter valid credential values:
    - `scripts-git-username`
    - `scripts-git-password`
    - `iaas-username`
    - `iaas-password`
    - `init-vm-username`
    - `init-vm-password`
- Upload pipeline
    - Edit `<repo>/set-pipelines.sh`
    - Verify `./set-pipeline.sh lite "./<pipeline-type>/pipeline.yml" "./<pipeline-type>/env/vsphere-pipeline-params.yml" "./credentials.yml" <pipeline-type>-vsphere-jumpbox`
    - Run `<repo>/set-pipelines.sh`

# Potential Improvements
- Adding file storage (S3?) for tfstate and ssh key files
- Research Stemcell usage for initial VM image
    - Experiencing Network/Permission releated issues with cloned VMs
