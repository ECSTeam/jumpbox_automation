#!/bin/bash

# Pull variables from vault

az cloud set --name AzureCloud
az login -u $AZURE_USERNAME -p $AZURE_PASSWORD
