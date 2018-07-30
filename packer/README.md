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
export AZURE_CLIENT_SECRET="my_packer_password"
export AZURE_RESOURCE_GROUP_NAME="training-lab-images"
export AZURE_SUBSCRIPTION_ID="$(az account list | jq -r '.[] | select (.isDefault == true).id')"

NAME=training-lab_kvm-ubuntu-16.04-server-amd64   packer build -only=azure-arm training-lab_ubuntu_image.json
NAME=training-lab_kvm01-ubuntu-16.04-server-amd64 packer build -only=azure-arm training-lab_ubuntu_image.json
```


## Qemu

```bash
export TMPDIR="$PWD/packer_cache"
NAME=training-lab_kvm-ubuntu-16.04-server-amd64   UBUNTU_CODENAME=xenial packer build -only=qemu training-lab_ubuntu_image.json
NAME=training-lab_kvm01-ubuntu-16.04-server-amd64 UBUNTU_CODENAME=xenial packer build -only=qemu training-lab_ubuntu_image.json
```


## VirtualBox

```bash
export TMPDIR="$PWD/packer_cache"
NAME=kvm-ubuntu-16.04-server-amd64   UBUNTU_CODENAME=xenial packer build -only=virtualbox-iso training-lab_ubuntu_image.json
NAME=kvm01-ubuntu-16.04-server-amd64 UBUNTU_CODENAME=xenial packer build -only=virtualbox-iso training-lab_ubuntu_image.json
```
