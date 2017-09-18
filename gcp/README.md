# Pre Reqs
- Pre existing project in GCP. We need the project identifier.
- Pre existing Service Account with access to create resources within the project


CREDS_TYPE
CREDS_PROJECT_ID
CREDS_PRIVATE_KEY_ID
CREDS_PRIVATE_KEY
CREDS_EMAIL
CREDS_CLIENT_ID
CREDS_CERT_URL

# Manual Deployment
- `cd <repo>/gcp/terraform`
- Copy `terraform.tfvars.example` to `terraform.tfvars`
- Uncomment and enter valid values: 
    - 
- run command `terraform apply`

# Concourse Deployment
- Pipeline types: `ci`, `deploy-insecure`, `deploy-secure`
    - CI: Runs Create and Verify tasks with an ensured Destroy step to clean up
    - Deploy-Insecure: Runs Create and Verify tasks to setup a VM
        - This pipeline will store credentials information as Environment Variables
    - Deploy-Secure: Runs Create and Verify tasks to setup a VM
        - This pipeline uses vault to store credentials protecting Service Account information
- Pipelines: `<repo>/<pipeline-type>/pipeline.yml`, `<repo>/deploy/pipeline-secure.yml`
- Configuration: `<repo>/<pipeline-type>/env/gcp-pipeline-params.yml`
- Copy `<repo>/credentials.yml.stub` to `<repo>/credentials.yml`
- Enter valid credential values:
    - `scripts-git-username`
    - `scripts-git-password`
- Upload pipeline
    - Edit `<repo>/set-pipelines.sh`
    - Verify `./set-pipeline.sh lite "./<pipeline-type>/pipeline.yml" "./<pipeline-type>/env/gcp-pipeline-params.yml" "./credentials.yml" <pipeline-type>-gcp-jumpbox`
    - Run `<repo>/set-pipelines.sh`

# Potential Improvements
- Adding file storage (S3?) for tfstate and ssh key files
- Research Stemcell usage for initial VM image
    - Experiencing Network/Permission releated issues with cloned VMs
