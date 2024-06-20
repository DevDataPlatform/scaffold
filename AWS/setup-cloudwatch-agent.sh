#!/bin/sh

ROOT_PEMFILE="secrets/ddp-airbyte.pem"
MACHINE_IP=`cat machineip.txt`

if [ "x${MACHINE_IP}" == "x" ]; then
  echo "Please set MACHINE_IP before running this script"
  exit 1
fi

echo "Installing Cloudwatch Agent"
downloadlink="https://s3.ap-south-1.amazonaws.com/amazoncloudwatch-agent-ap-south-1/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb"
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} wget ${downloadlink}
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

echo "Starting Cloudwatch Agent"
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s
scp -i ${ROOT_PEMFILE} amazon-cloudwatch-agent-config.json ubuntu@${MACHINE_IP}:config.json
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} sudo mv config.json /opt/aws/amazon-cloudwatch-agent/bin/config.json
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a remove-config -c all 
ssh -i ${ROOT_PEMFILE} ubuntu@${MACHINE_IP} sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a append-config -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s

# the config wizard is at /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
# the instance needs to be associated with an IAM role containing the "CloudwatchAgentServerPolicy" policy