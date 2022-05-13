#!/bin/bash

## Remove all the bottstrap
docker exec -it $(docker ps | grep ipfs | awk '{print $1}') sh -c 'ipfs bootstrap rm --all'


## Add the swarm key
sudo cp /home/ubuntu/efs-share/services/swarm.key /home/ubuntu/docker_ipfs/data/ipfs/
sudo chown ubuntu:ubuntu /home/ubuntu/docker_ipfs/data/ipfs/swarm.key
sudo chmod 400 /home/ubuntu/docker_ipfs/data/ipfs/swarm.key

## Restart the Container
docker container restart $(docker ps | grep ipfs | awk '{print $1}')

## Add Bootstrap record of the Other servers in Cluster
docker exec -it $(docker ps | grep ipfs | awk '{print $1}') sh -c 'ipfs bootstrap add /ip4/10.0.1.242/tcp/4001/p2p/QmTxYt7ktBmWL789tACUGDs1ii7qdaxDu3gxJCcnVGMnVB'
