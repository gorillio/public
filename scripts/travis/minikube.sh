#!/bin/bash
set -e
MINIKUBE_VERSION=1.8.1
KUBE_VERSION=1.18.1
echo "==============================================================================================================="
echo " minikube setup"
echo "==============================================================================================================="
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0${MINIKUBE_VERSION}/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/
mkdir -p $HOME/.kube $HOME/.minikube
touch $KUBECONFIG
echo "==============================================================================================================="
echo "minikube start"
echo "==============================================================================================================="
sudo minikube start --profile=minikube --vm-driver=none --kubernetes-version=v${KUBE_VERSION}
minikube update-context --profile=minikube
sudo chown -R travis: /home/travis/.minikube/
eval "$(minikube docker-env --profile=minikube)" && export DOCKER_CLI='docker'
echo "==============================================================================================================="
echo "wait for kube-system pod to be in running state"
echo "==============================================================================================================="
JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}'
until kubectl -n kube-system get pods -lk8s-app=kube-dns -o jsonpath="$JSONPATH" 2>&1 | grep -q "Ready=True"; \
  do sleep 5; \
  done;
