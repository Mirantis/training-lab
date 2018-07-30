#!/bin/bash -eu

# Cloud Platforms: openstack, azure, gce
CLOUD_PLATFORM=$(basename $0 | sed 's/.*_\(.*\).sh/\1/')

# Action create/delete
ACTION="$(basename $0 | sed 's/^\(.*\)_.*/\1/')"

echo "*** Cloud Platform: $CLOUD_PLATFORM, Action: $ACTION"

# Check if Terraform plugins are installed - if not install them
if [ ! -d "terraform/$CLOUD_PLATFORM/.terraform/plugins/" ]; then
  cd terraform/$CLOUD_PLATFORM/
  terraform init
  cd -
fi

if [ "$ACTION" == "delete" ]; then
  ansible-playbook --extra-vars "cloud_platform=$CLOUD_PLATFORM terraform_state=absent" -i 127.0.0.1, site.yml
else
  ansible-playbook --extra-vars "cloud_platform=$CLOUD_PLATFORM terraform_state=present" -i 127.0.0.1, site.yml
fi
