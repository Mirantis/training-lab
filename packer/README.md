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

## Qemu

```
TMPDIR="$PWD/packer_cache" NAME=kvm01-ubuntu-16.04-server-amd64 UBUNTU_CODENAME=xenial packer build -only=qemu training-lab_ubuntu_image.json
TMPDIR="$PWD/packer_cache" NAME=kvm-ubuntu-16.04-server-amd64   UBUNTU_CODENAME=xenial packer build -only=qemu training-lab_ubuntu_image.json
```

## VirtualBox

```
TMPDIR="$PWD/packer_cache" NAME=kvm01-ubuntu-16.04-server-amd64 UBUNTU_CODENAME=xenial packer build -only=virtualbox-iso training-lab_ubuntu_image.json
TMPDIR="$PWD/packer_cache" NAME=kvm-ubuntu-16.04-server-amd64   UBUNTU_CODENAME=xenial packer build -only=virtualbox-iso training-lab_ubuntu_image.json
```
