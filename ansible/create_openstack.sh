#!/bin/bash -e

# Docker executable
DOCKER_RUN="docker run --rm -it -u $(id -u):$(id -g) -v $PWD:/home/docker/training-lab -v $HOME/.ssh:/home/docker/.ssh -v $HOME/.azure:/home/docker/.azure -v /tmp:/tmp -v $SSH_AUTH_SOCK:/ssh-agent mirantis/training-lab"

# Cloud Platforms: openstack, azure
CLOUD_PLATFORM=$(basename $0 | sed 's/.*_\(.*\).sh/\1/')

# Action create/delete
ACTION="$(basename $0 | sed 's/^\(.*\)_.*/\1/')"

cd "$(dirname "$0")"

echo "*** Cloud Platform: $CLOUD_PLATFORM, Action: $ACTION"

# Check if Terraform plugins are installed - if not install them
if [ ! -d "terraform/$CLOUD_PLATFORM/.terraform/plugins/" ]; then
  cd terraform/$CLOUD_PLATFORM/
  docker run --rm -it -u $(id -u):$(id -g) -v $PWD:/home/docker/training-lab mirantis/training-lab terraform init
  cd -
fi

if [ "$CLOUD_PLATFORM" == "azure" ]; then
  # Check if your account is working properly
  if $DOCKER_RUN "az account show 2>&1" | grep "Please run 'az login' to setup account."; then
    echo "*** Running 'az login'"
    if [ -n "$CLIENT_ID" ] && [ -n "$CLIENT_SECRET" ] && [ -n "$TENANT_ID" ]; then
      # Use non-interactive login using service principal (https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli?view=azure-cli-latest)
      $DOCKER_RUN "az login --service-principal -u \"$CLIENT_ID\" -p \"$CLIENT_SECRET\" --tenant \"$TENANT_ID\""
    else
      # Use interactive login
      $DOCKER_RUN "az login"
    fi
  fi
fi

if [ "$ACTION" == "delete" ]; then
  $DOCKER_RUN "ansible-playbook --private-key \$HOME/.ssh/id_rsa --extra-vars \"cloud_platform=$CLOUD_PLATFORM terraform_state=absent prefix=${USER}\" -i 127.0.0.1, site.yml"
else
  $DOCKER_RUN "ansible-playbook --private-key \$HOME/.ssh/id_rsa --extra-vars \"cloud_platform=$CLOUD_PLATFORM terraform_state=present prefix=${USER}\" -i 127.0.0.1, site.yml"
fi
