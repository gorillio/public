#!/bin/bash

echo "==============================================================================================================="
echo " microk8s setup"
echo "==============================================================================================================="

microk8s.start
microk8s.status --wait-ready
microk8s.enable storage dns
microk8s.inspect
sudo snap alias microk8s.kubectl kubectl

echo "==============================================================================================================="
echo " Using microk8s docker daemon for the rest of operations"
echo "==============================================================================================================="
export DOCKER_HOST="unix:///var/snap/microk8s/current/docker.sock"
cat ~/travis.json | microk8s.docker login -u _json_key --password-stdin https://gcr.io
