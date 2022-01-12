#!/bin/bash -e

DOCKER_VERSION="5:20.10.7~3-0~ubuntu-xenial"
echo "==============================================================================================================="
echo "Update Docker version for BUILDKIT"
echo "==============================================================================================================="
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get -qq update
sudo apt-get -qq -y -o Dpkg::Options::="--force-confnew" install docker-ce=${DOCKER_VERSION}
docker --version

echo "==============================================================================================================="
echo "Clear out the setting 'registry-mirrors' from docker config file which causes buildkit to fail see https://github.com/moby/moby/issues/39120"
echo "==============================================================================================================="
sudo bash -c "echo -e '{\n\"mtu\":1500,\n\"registry-mirrors\":[\"https://mirror.gcr.io\"]\n}' > /etc/docker/daemon.json";

echo "==============================================================================================================="
echo "Restarting Docker service to put in effect"
echo "==============================================================================================================="
sudo service docker restart
docker system info

DOCKER_COMPOSE_VERSION="1.25.5"
echo "==============================================================================================================="
echo "Docker Compose for BUILDKIT support: Version: ${DOCKER_COMPOSE_VERSION}"
echo "==============================================================================================================="
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
docker-compose version

CONFTEST_VERSION="0.25.0"
echo "==============================================================================================================="
echo "Setup Conftest"
echo "==============================================================================================================="
wget https://github.com/open-policy-agent/conftest/releases/download/v${CONFTEST_VERSION}/conftest_${CONFTEST_VERSION}_linux_amd64.deb
sudo dpkg -i conftest_${CONFTEST_VERSION}_linux_amd64.deb

TRIVY_VERSION="0.22.0"
echo "==============================================================================================================="
echo "Setup Trivy"
echo "==============================================================================================================="
wget https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.deb
sudo dpkg -i trivy_${TRIVY_VERSION}_Linux-64bit.deb

echo "==============================================================================================================="
echo "Setup GCloud"
echo "==============================================================================================================="

openssl aes-256-cbc -K $ENC_KEY -iv $ENC_IV -in $ENC_FILE -out ${HOME}/travis.json -d
cat ~/travis.json | docker login -u _json_key --password-stdin https://gcr.io

echo "==============================================================================================================="
echo "Env Variables"
echo "==============================================================================================================="

export SHORT_SHA=$(git rev-parse --short HEAD)
export SHA=$(git rev-parse HEAD)
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
export GOOGLE_APPLICATION_CREDENTIALS=~/travis.json

