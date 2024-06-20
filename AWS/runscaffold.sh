#!/bin/sh

# ssh -i ddp-airbyte.pem ubuntu@13.235.78.203
# ssh -i ddp.id_rsa ddp@13.235.78.203

MACHINE_IP=`cat machineip.txt`

if [ "x${MACHINE_IP}" == "x" ]; then
  echo "Please set MACHINE_IP before running this script"
  exit 1
fi

# ==================================== Step 1 ====================================
sh waitformachine.sh
if [ $? -eq 1 ]; then 
  exit 1
fi
sh scaffold-1.sh

# ==================================== Step 2 ====================================
sh waitformachine.sh
if [ $? -eq 1 ]; then 
  exit 1
fi

sh scaffold-2.sh

# ==================================== Step 3 ====================================
nohup sh setup-airbyte.sh &

# give it some time to download images etc
sleep 120

nohup sh setup-prefect.sh &

nohup sh setup-ddpui.sh & 
