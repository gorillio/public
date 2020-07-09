#!/bin/bash

echo "==============================================================================================================="
echo " minikube setup"
echo "==============================================================================================================="

 # Download minikube.
- curl -Lo minikube https://storage.googleapis.com/minikube/releases/v1.8.1/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
- mkdir -p $HOME/.kube $HOME/.minikube
- touch $KUBECONFIG
- sudo minikube start --profile=minikube --vm-driver=none --kubernetes-version=v1.18.1
- minikube update-context --profile=minikube
- "sudo chown -R travis: /home/travis/.minikube/"
- eval "$(minikube docker-env --profile=minikube)" && export DOCKER_CLI='docker'
- JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}'; until kubectl -n kube-system get pods -lk8s-app=kube-dns -o jsonpath="$JSONPATH" 2>&1 | grep -q "Ready=True"; do sleep 1;echo "waiting for kube-dns to be available"; kubectl get pods --all-namespaces; done
