#!/bin/bash
set -e

KUBE_VERSION=1.18.1
CHANGE_MINIKUBE_NONE_USER=true
MINIKUBE_WANTUPDATENOTIFICATION=false
MINIKUBE_WANTREPORTERRORPROMPT=false
MINIKUBE_HOME=$HOME
CHANGE_MINIKUBE_NONE_USER=true
KUBECONFIG=$HOME/.kube/config

echo "==============================================================================================================="
echo " Setup minikube"
echo "==============================================================================================================="
curl -Lo  https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && \
    sudo mv minikube /usr/local/bin/minikube && \
    chmod +x /usr/local/bin/minikube
mkdir -p $HOME/.kube $HOME/.minikube
touch $KUBECONFIG

echo "==============================================================================================================="
echo " Staring minikube"
echo "==============================================================================================================="
sudo minikube start --profile=minikube --vm-driver=none --kubernetes-version=v${KUBE_VERSION}
minikube update-context --profile=minikube

echo "==============================================================================================================="
echo " Wait for kube-system pod to be in running state"
echo "==============================================================================================================="
JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}'
until kubectl -n kube-system get pods -lk8s-app=kube-dns -o jsonpath="$JSONPATH" 2>&1 | grep -q "Ready=True";  do { 
  sleep 5; 
  echo "Wating for minikube to be up..."
} done;

sudo chown -R travis: /home/travis/.minikube/
eval "$(minikube docker-env --profile=minikube)" && export DOCKER_CLI='docker'
