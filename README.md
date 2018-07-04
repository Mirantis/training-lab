# Training Lab

[![Build Status](https://travis-ci.org/Mirantis/training-lab.svg?branch=master)](https://travis-ci.org/Mirantis/training-lab)

You will need to have Terrafrom, az-cli and Ansible installed.


## Requirements

* [Terrafrom](https://www.terraform.io/)
* [az](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest) (Azure CLI)
* [Ansible](https://www.ansible.com/)
* few minor packages curl, git, jq, ...


## Network diagram

* Training lab - Architecture diagram

![Training lab - Architecture diagram](images/training-lab.png)

* Ansible + Terraform + Cloud Architecture

![Ansible + Terraform + Cloud Architecture](images/ansible_terraform.png)


### Azure related tasks

Few notes how to build the Training environment in Azure using [az](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest), [Terrafrom](https://www.terraform.io/) + [Ansible](https://www.ansible.com/).

Create Service Principal and authenticate to Azure - this should be done only once for the new Azure accounts:

* [https://www.terraform.io/docs/providers/azurerm/authenticating_via_service_principal.html](https://www.terraform.io/docs/providers/azurerm/authenticating_via_service_principal.html)

* [https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure)

```bash
echo "*** Login to the Azure CLI"
az login

echo "*** Get Subscription ID for Default Subscription"
SUBSCRIPTION_ID=$(az account list | jq -r '.[] | select (.isDefault == true).id')

echo "*** Create the Service Principal which will have permissions to manage resources in the specified Subscription"
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$SUBSCRIPTION_ID"

echo "*** Increase Token Lifetime (AccessTokenLifetime)"
```

* Login to Azure using Service Principal and check if it is working

```bash
az login --service-principal -u 0xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx -p fxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx --tenant 0xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
az vm list-sizes --location westus
```


### Ubuntu

Follow these commands to install necessary requirements on latest Ubuntu:

```bash
sudo apt install apt-transport-https ansible curl git gnupg jq lsb-release unzip

test -f $HOME/.ssh/id_rsa || ( install -m 0700 -d $HOME/.ssh && ssh-keygen -b 2048 -t rsa -f $HOME/.ssh/id_rsa -q -N "" )

# https://docs.microsoft.com/cs-cz/cli/azure/install-azure-cli-apt?view=azure-cli-latest
curl -L https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-get update && sudo apt-get install azure-cli

LATEST_TERRAFORM_VERISON=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version')
curl "https://releases.hashicorp.com/terraform/${LATEST_TERRAFORM_VERISON}/terraform_${LATEST_TERRAFORM_VERISON}_linux_amd64.zip" --output /tmp/terraform_linux_amd64.zip
sudo unzip /tmp/terraform_linux_amd64.zip -d /usr/local/bin/

git clone https://github.com/Mirantis/training-lab.git

cd training-lab/ansible/terraform/azure
terraform init
cd -
cd training-lab/ansible/terraform/openstack
terraform init
cd -

test -d ~/.ansible || mkdir ~/.ansible
echo "<my_secret_password>" > ~/.ansible/vault_training-lab.txt

# For editing the secrets you can use:
# ansible-vault edit --vault-password-file=~/.ansible/vault_training-lab.txt vars/openstack_secrets.yml

cd training-lab/ansible

# Create OpenStack training environment
./create_openstack.sh
# Delete whole OpenStack structure
./delete_openstack.sh

or

# Create Azure training environment
./create_azure.sh
# Delete whole Azure structure
./delete_azure.sh
```
