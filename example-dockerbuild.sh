#!/bin/bash

if [[ $(docker info) != *"Kernel Version:"* ]]; then
    echo "Unable to connect with Docker."
    exit 1
fi

PROJECT=docker-builder-pattern

read -r -d '' SCRIPT <<- End
    PORT=2376 /usr/local/bin/wrapdocker &
    export DOCKER_HOST=tcp://127.0.0.1:2376

    if [ ! -d /$PROJECT/jenkins-swarm-slave-nlm ]; then
      git clone https://github.com/sirkkalap/jenkins-swarm-slave-nlm-docker.git /$PROJECT/jenkins-swarm-slave-nlm
    fi

    cd /$PROJECT/jenkins-swarm-slave-nlm

    docker build -t sirkkalap/jenkins-swarm-slave-nlm .
End

IMG=jpetazzo/dind
MOUNT="-v $(pwd):/$PROJECT"
NAME="--name $PROJECT"
OPTS="-it --privileged --sig-proxy=true"

docker rm -f $PROJECT 2>/dev/null # Clean up old builds
docker run $OPTS $NAME $MOUNT $IMG /bin/bash -c "$SCRIPT"
