#!/bin/sh

MACHINE_IP=`cat machineip.txt`

# temp
GITBRANCH="master"

if [ "x${MACHINE_IP}" == "x" ]; then
  echo "Please set MACHINE_IP before running this script"
  exit 1
fi

if [ "x${DDPUSER}" == "x" ]; then
  DDPUSER="ddp"
fi

if [ "x${PROD}" == "x" ]; then
  DDP_PRIVATEKEYFILE="secrets/${DDPUSER}"
  if [ ! -f ${DDP_PRIVATEKEYFILE} ]; then
    echo "Private key missing for ${DDPUSER} please run scaffold-2"
    exit 1
  fi
  if [ "x${GITBRANCH}" == "x" ]; then
    echo "Please specify a branch to checkout for Airbyte by setting GITBRANCH"
    exit 1
  fi
else
  DDP_PRIVATEKEYFILE="ddp.id_rsa"
  GITBRANCH="Staging"
fi

echo "Downloading Airbyte"
giturl="https://github.com/DevDataPlatform/airbyte.git"
# giturl="https://github.com/airbytehq/airbyte.git"
ssh -i ${DDP_PRIVATEKEYFILE} ddp@${MACHINE_IP} "git clone -b ${GITBRANCH} --single-branch ${giturl}"


DATABASE_USER=`grep AIRBYTE_DATABASE_USER dbcreds.txt | cut -d "=" -f 2`
DATABASE_PASSWORD=`grep AIRBYTE_DATABASE_PASSWORD dbcreds.txt | cut -d "=" -f 2`
DATABASE_HOST=`grep AIRBYTE_DATABASE_HOST dbcreds.txt | cut -d "=" -f 2`
DATABASE_DB=`grep AIRBYTE_DATABASE_DB dbcreds.txt | cut -d "=" -f 2`

echo "Setting in airbyte/.env: DATABASE_USER=${DATABASE_USER}"
cmd_setuser="sed -i 's/DATABASE_USER=docker/DATABASE_USER=${DATABASE_USER}/' airbyte/.env"
ssh -i ${DDP_PRIVATEKEYFILE} ddp@${MACHINE_IP} ${cmd_setuser}

echo "Setting in airbyte/.env: DATABASE_PASSWORD=****************"
cmd_setpassword="sed -i 's/DATABASE_PASSWORD=docker/DATABASE_PASSWORD=${DATABASE_PASSWORD}/' airbyte/.env"
ssh -i ${DDP_PRIVATEKEYFILE} ddp@${MACHINE_IP} ${cmd_setpassword}

echo "Setting in airbyte/.env: DATABASE_HOST=${DATABASE_HOST}"
cmd_sethost="sed -i 's/DATABASE_HOST=db/DATABASE_HOST=${DATABASE_HOST}/' airbyte/.env"
ssh -i ${DDP_PRIVATEKEYFILE} ddp@${MACHINE_IP} ${cmd_sethost}

echo "Setting in airbyte/.env: DATABASE_DB=${DATABASE_DB}"
cmd_setdb="sed -i 's/DATABASE_DB=airbyte$/DATABASE_DB=${DATABASE_DB}/' airbyte/.env"
ssh -i ${DDP_PRIVATEKEYFILE} ddp@${MACHINE_IP} ${cmd_setdb}

DATABASE_URL="jdbc:postgresql://${DATABASE_HOST}:5432/${DATABASE_DB}"
echo "Setting in airbyte/.env: DATABASE_URL=${DATABASE_URL}"
cmd_setdb="sed -i 's|DATABASE_URL=jdbc:postgresql://db:5432/airbyte|DATABASE_URL=${DATABASE_URL}|' airbyte/.env"
ssh -i ${DDP_PRIVATEKEYFILE} ddp@${MACHINE_IP} ${cmd_setdb}

# we also need to add at the bottom:
# SECRET_PERSISTENCE=GOOGLE_SECRET_MANAGER
# SECRET_STORE_GCP_PROJECT_ID=<project id>
# SECRET_STORE_GCP_CREDENTIALS='<json as single-line string>'

scp -i ${DDP_PRIVATEKEYFILE} _startairbyte.sh ddp@${MACHINE_IP}:/home/${DDPUSER}/startairbyte.sh

# nohup ssh -i ${DDP_PRIVATEKEYFILE} ddp@${MACHINE_IP} "sh startairbyte.sh" 

