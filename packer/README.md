# Training Lab - images

It's handy to have some prebuild images for kvm01 and "other" nodes to speed up the installation process.
Here is the description how you can build such images using Packer on the following platforms:

* OpenStack
* Azure
* Qemu
* VirtualBox

## Requirements

* [Packer](https://www.packer.io/)
* [Ansible](https://www.ansible.com/)

## Openstack

## Azure

```bash
export AZURE_CLIENT_ID="$(az ad app list | jq -r '.[] | select (.displayName == "packerbuild").appId')"
read -s -p "Azure Password for Client ID \"$AZURE_CLIENT_ID\": " AZURE_CLIENT_SECRET
export AZURE_CLIENT_SECRET
export AZURE_RESOURCE_GROUP_NAME="training-lab-images"
export AZURE_SUBSCRIPTION_ID="$(az account list | jq -r '.[] | select (.isDefault == true).id')"

NAME=training-lab_kvm-ubuntu-16.04-server-amd64   packer build -only=azure-arm training-lab_ubuntu_image.json
NAME=training-lab_kvm01-ubuntu-16.04-server-amd64 packer build -only=azure-arm training-lab_ubuntu_image.json
```

## Openstack

```bash
export OPENSTACK_IDENTITY_ENDPOINT="https://cloud-cz.bud.mirantis.net:5000/v2.0"
export OPENSTACK_TENANT_NAME="mirantis-services"
export OPENSTACK_USERNAME="mirantis-services"
read -s -p "Openstack Password for user \"$OPENSTACK_USERNAME\": " OPENSTACK_PASSWORD
export OPENSTACK_PASSWORD
export OPENSTACK_AVAILABILITY_ZONE="nova"
export OPENSTACK_SOURCE_IMAGE_NAME="xenial-server-cloudimg-amd64-disk1-20180731"
export OPENSTACK_FLAVOR="m1.medium"
export OPENSTACK_NETWORK="4e34055c-4764-4995-b769-e5f43d3618ba"
export OPENSTACK_FLOATING_IP_POOL="public"
export OPENSTACK_SECURITY_GROUP="allow_all"

NAME=$USER-training-lab_kvm-ubuntu-16.04-server-amd64   packer build -only=openstack training-lab_ubuntu_image.json
NAME=$USER-training-lab_kvm01-ubuntu-16.04-server-amd64 packer build -only=openstack training-lab_ubuntu_image.json
```

## Qemu

```bash
mkdir $PWD/packer_cache
export TMPDIR="$PWD/packer_cache"
NAME=training-lab_kvm-ubuntu-16.04-server-amd64   UBUNTU_CODENAME=xenial packer build -only=qemu training-lab_ubuntu_image.json
NAME=training-lab_kvm01-ubuntu-16.04-server-amd64 UBUNTU_CODENAME=xenial packer build -only=qemu training-lab_ubuntu_image.json
```

## VirtualBox

```bash
mkdir $PWD/packer_cache
export TMPDIR="$PWD/packer_cache"
NAME=training-lab_kvm-ubuntu-16.04-server-amd64   UBUNTU_CODENAME=xenial packer build -only=virtualbox-iso training-lab_ubuntu_image.json
NAME=training-lab_kvm01-ubuntu-16.04-server-amd64 UBUNTU_CODENAME=xenial packer build -only=virtualbox-iso training-lab_ubuntu_image.json
```
