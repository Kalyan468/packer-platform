#!/usr/bin/env bash

function az_login() {
    echo "login ${ARM_CLIENT_ID}"
    az login --service-principal -u "${ARM_CLIENT_ID}" --password "${ARM_CLIENT_SECRET}" --tenant "${ARM_TENANT_ID}" > /dev/null
    az account set -s "${ARM_SUBSCRIPTION_ID}" > /dev/null
}
