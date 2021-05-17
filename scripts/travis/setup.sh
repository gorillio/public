#!/bin/bash -e

echo "==============================================================================================================="
echo "Update Docker version for BUILDKIT"
echo "==============================================================================================================="
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get -qq update
sudo apt-get -qq -y -o Dpkg::Options::="--force-confnew" install docker-ce

echo "==============================================================================================================="
echo "Clear out the setting 'registry-mirrors' from docker config file which causes buildkit to fail see https://github.com/moby/moby/issues/39120"
echo "==============================================================================================================="
sudo bash -c "echo '{}' > /etc/docker/daemon.json"

echo "==============================================================================================================="
echo "Restarting Docker service to put in effect"
echo "==============================================================================================================="
sudo service docker restart

DOCKER_COMPOSE_VERSION="1.25.5"
echo "==============================================================================================================="
echo "Docker Compose for BUILDKIT support: Version: ${DOCKER_COMPOSE_VERSION}"
echo "==============================================================================================================="
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
docker-compose version
