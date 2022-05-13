#!/bin/bash
# Mount the EFS share
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-032bf74820a9697bd.efs.ca-central-1.amazonaws.com:/ /home/ubuntu/efs-share

## Statr the Docker compose
cd /home/ubuntu/docker
sudo docker-compose up -d
