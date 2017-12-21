# Pre Reqs
In order to create a Vsphere VM via terraform you need a template to clone. Therefore ensure you have an Existing base image (available to the lab/login you are using) in vSphere. This image can be any valid VM template. Currently we are staying with a bare ISO install. If you do not have one follow these steps:

    1. Download ISO https://www.ubuntu.com/download/server
        - Scripts have been verified to work with Ubuntu 16.04
    2. Upload the ISO to vSphere
    3. Create new VM with ISO attached
        - New Virtual Machine->New Virtual Machine...->Follow Wizard to "Customize hardware"
          - Name the new VM something sensible...like "Ubuntu-16-template"
          - Choose appropriate values for lab in question for DC/DataStore/etc...
          - Compatible with ESXi 6.5 and later
          - Guest OS - linux
          - OS Version - Ubuntu 64 bit
          - Customize hardware
            - 1 CPU
            - 4096 MB memory
            - 20 GB Disk
            - Change "New CD/DVD Drive" to "Datasource ISO File" and select uploaded ISO.
              - Check the "Connect At Power On" box
            - Delete the Floppy Drive (you don't need or want one!)
    4. Power on VM. This will start the OS installation. Expand the VM console and answer questions accordingly.
        - If given the option choose to activate ssh server!
        - Disk partitioning select "Guided - use entire disk (with LVM)".
    5. Setup initial User `ubuntu`
    6. Once installation is complete login to the new VM using the 'ubuntu' user
        - Disable sudo password entry for the `ubuntu` user
          - `sudo visudo`
          - Add `ubuntu ALL=(ALL) NOPASSWD: ALL` to the bottom of the file.
          - Turn on ssh - `sudo service ssh start` (or ensure it is running)
    7. Stop the VM (power it off. The VM must be off to be cloned.)
    8. Take a snapshot of the VM (to be used as a clone linked template it must only 1 snapshot.)

# Manual Deployment
  1. Ensure the pre-reqs are met
  2. Clone or get latest on the jumpbox_automation repo
  3. `cd <repo>/vsphere/terraform`
  4. Edit the setup-env.sh script
      - Enter appropriate values for the variables
  5. Edit `terraform.tfvars.example`
      - Enter appropriate values for the variables
  6. run command `terraform apply`

# Concourse Deployment
  1. Ensure the pre-reqs are met
  2. Pipeline types: `ci`, `deploy`
      - CI: Runs the Create and Verify tasks with an ensured Destroy step to clean up
      - Deploy: Runs the Create and Verify tasks to setup a VM
  3. Pipelines: `<repo>/<pipeline-type>/pipeline.yml`
  4. Configuration: `<repo>/<pipeline-type>/env/vsphere-pipeline-params.yml`
  5. Copy `<repo>/credentials.yml.stub` to `<repo>/credentials.yml`
  6. Enter valid credential values:
      - `scripts-git-username`
      - `scripts-git-password`
      - `iaas-username`
      - `iaas-password`
      - `init-vm-username`
      - `init-vm-password`
  7. Upload pipeline
      - Edit `<repo>/set-pipelines.sh`
      - Verify `./set-pipeline.sh lite "./<pipeline-type>/pipeline.yml" "./<pipeline-type>/env/vsphere-pipeline-params.yml" "./credentials.yml" <pipeline-type>-vsphere-jumpbox`
      - Run `<repo>/set-pipelines.sh`

# Potential Improvements
- Adding file storage (S3?) for tfstate and ssh key files
- Research Stemcell usage for initial VM image
> Note: At some point someone was Experiencing Network/Permission related issues with cloned VMs
