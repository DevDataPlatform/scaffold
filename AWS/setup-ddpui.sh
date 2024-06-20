#!/bin/sh

MACHINE_IP=`cat machineip.txt`

if [ "x${MACHINE_IP}" == "x" ]; then
  echo "Please set MACHINE_IP before running this script"
  exit 1
fi

DDPUSER="ddp"

# run ssh-keygen on local machine for development builds
# for production we need a stronger guarantee that we won't be locked out, so we re-use a known key pair
if [ "x${PROD}" == "x" ]; then
  DDP_PRIVATEKEYFILE="secrets/${DDPUSER}"
  if [ ! -f ${DDP_PRIVATEKEYFILE} ]; then
    echo "Private key missing for ${DDPUSER} please run scaffold-2"
    exit 1
  fi
else
  DDP_PRIVATEKEYFILE="secrets/ddp.id_rsa"
fi

scp -i ${DDP_PRIVATEKEYFILE} _setupddpui.sh ddp@${MACHINE_IP}:/home/ddp/setupddpui.sh
ssh -i ${DDP_PRIVATEKEYFILE} ddp@${MACHINE_IP} "sh setupddpui.sh"
