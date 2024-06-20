#!/bin/bash

# Update the apt package index
sudo apt-get update

# Install packages to allow apt to use a repository over HTTPS
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add Docker apt repository.
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update the apt package index
sudo apt-get update

# Install the latest version of Docker CE and containerd
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Execute the Docker command without sudo (optional)
# If you do this, you may need to log out and log back in to refresh the group membership
sudo usermod -aG docker $USER
if command -v systemctl &> /dev/null
then
  systemctl restart docker
fi

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# fix permission denied error
sudo apt-get install -y acl jq
sudo setfacl -m user:$USER:rw /var/run/docker.sock

# Output the version of docker and docker-compose to verify installation
docker --version
docker-compose --version