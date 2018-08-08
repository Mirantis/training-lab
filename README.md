# Training Lab

[![Build Status](https://travis-ci.org/Mirantis/training-lab.svg?branch=master)](https://travis-ci.org/Mirantis/training-lab)

You will need to have Docker installed.

## Requirements

* [Docker](https://www.docker.com/)

## Network diagram

* Training lab - Architecture diagram

![Training lab - Architecture diagram](images/training-lab.png)

* Ansible + Terraform + Cloud Architecture

![Ansible + Terraform + Cloud Architecture](images/ansible_terraform.png)

## Azure related tasks

Few notes how to build the Training environment in Azure using prebuilded Docker image.
Docker image contains [az](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest), [Terraform](https://www.terraform.io/) + [Ansible](https://www.ansible.com/).

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

echo "*** Login to Azure using Service Principal and check if it is working"
az login --service-principal -u 0xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx -p fxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx --tenant 0xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
az vm list-sizes --location westus
```

### Create DNS zone

See the details: [https://docs.microsoft.com/en-us/azure/dns/dns-delegate-domain-azure-dns](https://docs.microsoft.com/en-us/azure/dns/dns-delegate-domain-azure-dns)

```bash
# Create resource group
az group create --name training-lab-dns --location "East US 2"
az network dns zone create -g training-lab-dns -n tng.mirantis.com

# List DNS nameservers for zone tng.mirantis.com in Azure
# You need to ask the domain owner to delegate the zone "tng.mirantis.com" to the Azure nameservers
az network dns zone show -g training-lab-dns -n tng.mirantis.com -o json

# Add default "www" CNAME to training.mirantis.com
az network dns record-set cname set-record -g training-lab-dns -z tng.mirantis.com -n www -c training.mirantis.com
```

### Create Resource Group holding the images created by packer (optional)

Building own images will speed up the deployment process.
Details can be found here: [https://www.packer.io/docs/builders/azure-setup.html](https://www.packer.io/docs/builders/azure-setup.html) and [https://github.com/hashicorp/packer/blob/master/contrib/azure-setup.sh](https://github.com/hashicorp/packer/blob/master/contrib/azure-setup.sh)

```bash
# Create resource group
az group create --name training-lab-images --location "East US 2"

echo "*** Create application"
az ad app create --display-name "packerbuild" --identifier-uris http://packerbuild --homepage http://packerbuild --password my_packer_password

# Change password: az ad app update --id $(az ad app list | jq -r '.[] | select (.displayName == "packerbuild").appId') --password fxxxxxxxxxxxxxxf

echo "*** Get application id"
CLIENT_ID=$(az ad app list | jq -r '.[] | select (.displayName == "packerbuild").appId')

echo "*** Create service principal"
az ad sp create --id $CLIENT_ID

echo "*** Get service principal id"
OBJECT_ID=$(az ad sp list | jq -r '.[] | select (.displayName == "packerbuild").objectId')

echo "*** Get Subscription ID for Default Subscription"
SUBSCRIPTION_ID=$(az account list | jq -r '.[] | select (.isDefault == true).id')

echo "*** Create permissions"
az role assignment create --assignee $OBJECT_ID --role "Owner" --scope /subscriptions/$SUBSCRIPTION_ID
```

## Build your own images

The standard deployment process download many packages / huge images / repositories form Internet which takes a lot of time.
Build your own images for OpenStack / Azure / local testing to speed up the deployment.

### Build azure images

```bash
export AZURE_CLIENT_ID="$(az ad app list | jq -r '.[] | select (.displayName == "packerbuild").appId')"
export AZURE_CLIENT_SECRET="my_packer_password"
export AZURE_RESOURCE_GROUP_NAME="training-lab-images"
export AZURE_SUBSCRIPTION_ID="$(az account list | jq -r '.[] | select (.isDefault == true).id')"

NAME=training-lab_kvm-ubuntu-16.04-server-amd64   packer build -only=azure-arm training-lab_ubuntu_image.json
NAME=training-lab_kvm01-ubuntu-16.04-server-amd64 packer build -only=azure-arm training-lab_ubuntu_image.json
```

Please check the [packer](packer) directory for more details.

## Build environment on Ubuntu

Follow these commands to install necessary requirements on latest Ubuntu:

```bash
# You can use docker image:
# docker run -e "USER=$USER" --privileged --rm -it ubuntu:latest

sudo apt update -qq
sudo apt install -y curl docker.io git openssh-client sudo

# Change the default docker networking if needed
cat > /etc/docker/daemon.json << EOF
{
  "bip": "192.168.150.1/24",
  "fixed-cidr": "192.168.150.0/24"
}
EOF

sudo service docker start

test -f $HOME/.ssh/id_rsa || ( install -m 0700 -d $HOME/.ssh && ssh-keygen -b 2048 -t rsa -f $HOME/.ssh/id_rsa -q -N "" )

git clone https://github.com/Mirantis/training-lab.git

read -s -p "Ansible Vault Password for Training Lab: " MY_ANSIBLE_VAULT_TRAINIG_LAB_PASSWORD
echo "$MY_ANSIBLE_VAULT_TRAINIG_LAB_PASSWORD" > training-lab/ansible/vault_training-lab.txt

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

[![asciicast](https://asciinema.org/a/194279.png)](https://asciinema.org/a/194279)

## Deployment steps on kvm01

[https://docs.mirantis.com/mcp/master/mcp-deployment-guide/single/index.html](https://docs.mirantis.com/mcp/master/mcp-deployment-guide/single/index.html) (Start from: To create control plane VMs:)

```bash
# Log in to the Salt Master node console
$ virsh console cfg01.tng.mirantis.com

# Verify that all your Salt Minion nodes are registered on the Salt Master node
$ salt-key
Accepted Keys:
cfg01.tng.mirantis.com
kvm01.tng.mirantis.com
kvm02.tng.mirantis.com
kvm03.tng.mirantis.com
Denied Keys:
Unaccepted Keys:
Rejected Keys:

# Check salt versions
$ salt '*' test.version
kvm03.tng.mirantis.com:
    2017.7.5
kvm02.tng.mirantis.com:
    2017.7.5
kvm01.tng.mirantis.com:
    2017.7.5
cfg01.tng.mirantis.com:
    2017.7.5

# Verify that the Salt Minion nodes are synchronized by running the following command on the Salt Master node
$ salt '*' saltutil.sync_all

# Refresh Salt pillars
$ salt '*' saltutil.refresh_pillar

# Check out your inventory to be able to resolve any inconsistencies in your model:
$ reclass-salt --top

# Perform the initial Salt configuration
$ salt '*kvm*' state.sls salt.minion

# Set up the network interfaces and the SSH access
$ salt -C 'I@salt:control' cmd.run 'salt-call state.sls linux.system.user,openssh,linux.network;reboot'

$ salt 'kvm*' state.sls libvirt
```
