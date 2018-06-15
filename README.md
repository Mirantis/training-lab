# Training Lab

[![Build Status](https://travis-ci.org/Mirantis/training-lab.svg?branch=master)](https://travis-ci.org/Mirantis/training-lab)

You will need to have Terrafrom, az-cli and Ansible installed.

## Requirements

* Terrafrom
* [az](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest) (Azure CLI)
* Ansible

Download Terraform components:

```
cd ansible/terraform/azure
terraform init
cd -
cd ansible/terraform/openstack
terraform init
```

## Openstack

Few notes how to build the Training environment in OpenStack

```
cd ansible
./create_openstack.sh

# Delete whole structure
./delete_openstack.sh
```

## Azure

Few notes how to build the Training environment in Azure using [az](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest), Terraform + Ansible.

Create Service Principal and authenticate to Azure - this should be done only once for the new Azure accounts:
* https://www.terraform.io/docs/providers/azurerm/authenticating_via_service_principal.html
* https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure

```
echo "*** Login to the Azure CLI"
az login

echo "*** Get Subscription ID for Default Subscription"
SUBSCRIPTION_ID=$(az account list | jq -r '.[] | select (.isDefault == true).id')

echo "*** Create the Service Principal which will have permissions to manage resources in the specified Subscription"
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$SUBSCRIPTION_ID"

echo "*** Increase Token Lifetime (AccessTokenLifetime)"
```

* Login to Azure using Service Principal and check if it is working

```
az login --service-principal -u 0xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx -p fxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx --tenant 0xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
az vm list-sizes --location westus
```

* Provision VMs

```
cd ansible
./create_azure.sh

# Delete whole structure
./delete_azure.sh
```
