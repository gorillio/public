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
export GOOGLE_APPLICATION_CREDENTIALS=~/travis.json

