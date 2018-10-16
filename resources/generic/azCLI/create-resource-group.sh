#!/usr/bin/env bash

resource_group_name=$1
resource_group_location=${2:-North Europe}

source "$(dirname $0)/lib/auth.sh"
az_login

resource_group_id=$(az group show --name "${resource_group_name}" -o tsv --query id)
if [ -z ${resource_group_id} ]; then
  echo "resource group ${resource_group_name} doesn't exist, creating it..."
  az group create --name "${resource_group_name}" --location "${resource_group_location}"
else
  echo "resource group ${resource_group_name} already exists, continuing..."
fi
