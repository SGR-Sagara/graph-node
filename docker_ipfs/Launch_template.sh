#!/bin/bash
## Install Docker
sudo apt update -y
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt-cache policy docker-ce
sudo apt install docker-ce -y
sudo usermod -aG docker ${USER}


## Install Docker-Compose
mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose
sudo chown $USER /var/run/docker.sock

## Install AWS CLI
sudo apt install unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

## Install Docker-Compose
sudo apt  install docker-compose -y

## Mount EFS
sudo apt update -y
sudo mkdir -p /home/ubuntu/efs-share
sudo chmod +XXX /home/ubuntu/efs-share
sudo apt-get -y install nfs-common
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-032bf74820a9697bd.efs.ca-central-1.amazonaws.com:/ /home/ubuntu/efs-share


## Copy the file to local machine
sudo cp -rf /home/ubuntu/efs-share/custom-graph-node/graph-node/docker_ipfs /home/ubuntu/

## Go to Docker Compose
cd /home/ubuntu/docker_ipfs
sudo docker-compose up -d

## Add a crontab to start docker compose at restart
#crontab<<EOF
#$(crontab -l)
#@reboot /home/ubuntu/efs-share/start_up.sh
#EOF


## Add docker group to user
sudo usermod -a -G docker ubuntu

## Load Environment variables from SSM Parameter Store
export IPFS_CLUSTER_PATH=$(aws --region=ca-central-1 ssm get-parameters --names 'IPFS_CLUSTER_PATH' --query "Parameters[0].Value" --output text)
export CLUSTER_SECRET=$(aws --region=ca-central-1 ssm get-parameters --names 'CLUSTER_SECRET' --query "Parameters[0].Value" --output text)

## ENV values
sudo cp /home/ubuntu/efs-share/services/environemnt_add.sh /etc/profile.d/environemnt_add.sh
sudo chmod 755 /etc/profile.d/environemnt_add.sh

## Copy IPFS Cluster related package to local server and set permission
sudo cp /home/ubuntu/efs-share/ipfsc-lib/ipfs-cluster-ctl/ipfs-cluster-ctl /home/ubuntu/efs-share/ipfsc-lib/ipfs-cluster-service/ipfs-cluster-service  /bin/
sudo chmod 755 /bin/ipfs*

## Add ipfs cluster service file and set permission
sudo cp /home/ubuntu/efs-share/services/ipfsc.service  /usr/lib/systemd/system/ipfsc.service
#sudo cp /home/ubuntu/efs-share/services/ipfsc-node.service  /usr/lib/systemd/system/ipfsc.service
sudo chmod 755 /usr/lib/systemd/system/ipfsc.service
sudo systemctl daemon-reload

## Initialize the IPFS cluster in server
ipfs-cluster-service init

## Add Permission to the Cluster folder
sudo chown ubuntu:ubuntu -R /home/ubuntu/.ipfs-cluster
#sudo chown ubuntu:ubuntu /home/ubuntu.ipfs-cluster/*
sudo chmod 755 -R /home/ubuntu/.ipfs-cluster
#sudo chmod 777 /home/ubuntu/.ipfs-cluster/*

## set the new Secret value to service.json
sed -i "/secret/c\    "\"secret\"": \"${CLUSTER_SECRET}\"," /home/ubuntu/.ipfs-cluster/service.json

## Start Cluster service
sudo systemctl restart ipfsc