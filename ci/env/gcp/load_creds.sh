#!/bin/bash

# Pull variables from vault

echo $GCP_CREDS_FILE > service_account_creds.json

gcloud auth activate-service-account --key-file service_account_creds.json
gcloud config set project $GCP_PROJECT

export TF_VAR_project=$GCP_PROJECT
