#!/bin/sh

ROOT_PEMFILE="../../secrets/superset.pem"
MACHINE_IP=`cat machineip.txt`

# basic packages
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} sudo apt update
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} sudo apt upgrade -y

# docker
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} sudo apt install docker.io -y

# postgres
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} sudo apt install -y postgresql postgresql-contrib

# docker compose v2
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} sudo apt-get install ca-certificates curl gnupg
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} sudo install -m 0755 -d /etc/apt/keyrings
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg"
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} sudo chmod a+r /etc/apt/keyrings/docker.gpg
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} 'echo   "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null'
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} sudo apt-get update
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} sudo apt-get install docker-compose-plugin
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} sudo usermod -a -G docker,sudo ubuntu

# docker-compose repo
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} git clone https://github.com/DalgoT4D/docker-superset.git

# reboot
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} sudo reboot

