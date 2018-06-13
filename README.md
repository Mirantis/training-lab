# Training Lab

[![Build Status](https://travis-ci.org/Mirantis/training-lab.svg?branch=master)](https://travis-ci.org/Mirantis/training-lab)

## Openstack

Few notes how to build the Training environment in OpenStack using Terraform

```
cd terraform/openstack

cat > terraform.tfvars << EOF
openstack_auth_url                     = "https://lab.mirantis.com:5000/v2.0"
openstack_compute_instance_image_name  = "oscore-ubuntu-16-04-amd64-mcp2018.4.0"
openstack_compute_instance_flavor_name = "m1.small"
openstack_password                     = "xxxxxxxx"
openstack_tenant_name                  = "xxxxxx"
openstack_user_name                    = "xxxxxx"
prefix                                 = "ruzickap"
EOF

terraform apply
```

## Azure

Few notes how to build the Training environment in Azure using [az](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest) and sing Terraform.

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
cd terraform/azure

cat > terraform.tfvars << EOF
azure_tags = { Environment = "Training", Consumer = "pruzicka@mirantis.com" }
prefix   = "ruzickap"
EOF

terraform apply
```
