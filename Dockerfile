FROM ubuntu:latest
LABEL MAINTAINER="Petr Ruzicka <petr.ruzicka@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive

RUN addgroup --gid 1001 docker && \
    adduser --uid 1001 --ingroup docker --home /home/docker --shell /bin/sh --disabled-password --gecos "" docker

RUN set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends curl git jq openssh-client python python3-pip python3-setuptools python3-wheel unzip \
    \
    && pip3 --no-cache-dir install ansible ansible[azure] azure-cli netaddr openstacksdk \
    \
    && TERRAFORM_LATEST_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version') \
    && curl https://releases.hashicorp.com/terraform/${TERRAFORM_LATEST_VERSION}/terraform_${TERRAFORM_LATEST_VERSION}_linux_amd64.zip --output /tmp/terraform_linux_amd64.zip \
    && unzip /tmp/terraform_linux_amd64.zip -d /usr/local/bin/ \
    && rm -f /tmp/terraform_linux_amd64.zip \
    \
    && curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.4/fixuid-0.4-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - \
    && chown root:root /usr/local/bin/fixuid \
    && chmod 4755 /usr/local/bin/fixuid \
    && mkdir -p /etc/fixuid \
    && printf "user: docker\ngroup: docker\npaths:\n  - /home/docker" > /etc/fixuid/config.yml \
    \
    && apt-get purge -y curl git jq python3-pip unzip \
    && rm -Rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean \
    && echo '#!/bin/bash\n\neval $( fixuid -q )\neval $*' > docker_startup_script.sh \
    && chmod a+x docker_startup_script.sh

USER docker:docker

ENV HOME /home/docker
ENV SSH_AUTH_SOCK /ssh-agent

WORKDIR /home/docker/training-lab

ENTRYPOINT ["/docker_startup_script.sh"]
