#!/bin/sh

# OS updates
# Package installation

ROOT_PEMFILE="secrets/ddp-airbyte.pem"
MACHINE_IP=`cat machineip.txt`

if [ "x${MACHINE_IP}" == "x" ]; then
  echo "Please set MACHINE_IP before running this script"
  exit 1
fi

echo "Updating packages..."
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} sudo apt update
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} sudo apt upgrade -y

echo "Installing docker"
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} sudo apt install docker.io -y
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} sudo apt install unzip -y 

echo "Installing venv for python 3.10"
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} "sudo apt install python3.10-venv -y"
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} "sudo apt install pip -y"

echo "Installing AWS CLI"
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} unzip awscliv2.zip
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} sudo ./aws/install

# yarn
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} sudo curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} sudo apt update
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} sudo apt install -y yarn

# postgres and psql
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} sudo apt install -y postgresql postgresql-contrib

# redis
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} sudo apt install -y redis-server

# nginx
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} sudo apt install -y nginx

# docker compose v2
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP}  sudo apt-get update
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP}  sudo apt-get install ca-certificates curl gnupg
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP}  sudo install -m 0755 -d /etc/apt/keyrings
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP}  "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg"
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP}  sudo chmod a+r /etc/apt/keyrings/docker.gpg
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP}  'echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null'
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP}  sudo apt-get update
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP}  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# certbot
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP}  sudo snap install --classic certbot
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP}  sudo ln -s /snap/bin/certbot /usr/bin/certbot


echo "Restarting machine"
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} sudo reboot

