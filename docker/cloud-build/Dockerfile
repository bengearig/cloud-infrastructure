FROM google/cloud-sdk

# PREREQUISITES
RUN apt-get update && apt-get install -y gnupg software-properties-common wget

# TERRAFORM
RUN wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN gpg --no-default-keyring \
    --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    --fingerprint
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
RUN apt update
RUN apt-get install -y terraform

# DOCKER
RUN mkdir -p /builder/home/.docker
RUN mkdir -p /root/.docker
RUN touch /root/.docker/config.json
RUN ln -s /root/.docker/config.json /builder/home/.docker/config.json
RUN apt install -y docker.io
