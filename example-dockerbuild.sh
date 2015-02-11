#!/bin/bash

echo "Note: Since dind has it's own images and they are stored in a volume, running this will eat disk space."
echo "See: docker images"
sleep 3

if [[ $(docker info) != *"Kernel Version:"* ]]; then
    echo "Unable to connect with Docker."
    exit 1
fi

PROJECT=docker-builder-pattern
SUBPROJECT=java-maven

read -r -d '' SCRIPT <<- End
    PORT=2376 /usr/local/bin/wrapdocker &
    export DOCKER_HOST=tcp://127.0.0.1:2376

    if [ ! -d /$PROJECT/$SUBPROJECT ]; then
        git clone https://github.com/sirkkalap/$SUBPROJECT-docker.git /$PROJECT/$SUBPROJECT-docker
    fi

    cd /$PROJECT/$SUBPROJECT-docker
    git checkout -b java7

    docker build -t sirkkalap/$SUBPROJECT .
End

IMG=jpetazzo/dind
MOUNT="-v $(pwd):/$PROJECT"
NAME="--name $PROJECT"
OPTS="-it --privileged --sig-proxy=true"

docker rm -f $PROJECT 2>/dev/null # Clean up old builds
docker run $OPTS $NAME $MOUNT $IMG /bin/bash -c "$SCRIPT"
