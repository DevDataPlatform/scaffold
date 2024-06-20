#!/bin/sh

MACHINE_IP=`cat machineip.txt`

ssh -i secrets/ddp-airbyte.pem -L 8000:localhost:8000 \
                       -L 9876:localhost:8888 \
                       -L 9081:localhost:8081 \
                       -L 9082:localhost:8082 \
                       -L 9083:localhost:8083 \
    ubuntu@${MACHINE_IP}
