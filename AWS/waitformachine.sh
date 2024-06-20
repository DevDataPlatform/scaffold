#!/bin/sh

ROOT_PEMFILE="secrets/ddp-airbyte.pem"
MACHINE_IP=`cat machineip.txt`

if [ "x${MACHINE_IP}" == "x" ]; then
  echo "Please set MACHINE_IP before running this script"
  exit 1
fi

attempts=1
maxattempts=10
while [ $attempts -lt $maxattempts ]
do
  echo "Sleeping for 10 seconds..."
  sleep 10
  echo "Checking if machine is up ($attempts out of $maxattempts)"
  ssh -i ${ROOT_PEMFILE} -o ConnectTimeout=3 ubuntu@${MACHINE_IP} exit 2
  if [ $? -eq 2 ]; then
    echo "Machine is up"
    break
  fi
  attempts=`expr $attempts + 1`
done

if [ $attempts -gt $maxattempts ]; then
  echo "Machine still not up, quitting"
  exit 1
fi

exit 0
