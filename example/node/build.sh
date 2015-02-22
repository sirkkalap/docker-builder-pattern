#!/bin/bash

if [[ $(docker info) != *"Kernel Version:"* ]]; then
    echo "Unable to connect with Docker."
    exit 1
fi

PROJECT=angular-ui/ui-select
CONTAINER_NAME=ui-select-build

read -r -d '' SCRIPT <<- End
    cd $PROJECT
    Xvfb :1 -ac &
    export DISPLAY=:1

    sudo npm install -g bower gulp
    npm install && bower install
    gulp
End

# https://github.com/sirkkalap/jenkins-swarm-slave-nlm-docker
IMG=sirkkalap/jenkins-swarm-slave-nlm
MOUNT="-v $(pwd):/home/jenkins-slave/$PROJECT"
NAME="--name $CONTAINER_NAME"
OPTS="-it --sig-proxy=true"

VOLFROM=$(docker ps -a | grep -o $CONTAINER_NAME-volume)
if [ ! -z $VOLFROM ]; then
    VOLFROM="--volumes-from $VOLFROM"
else
    echo "To make persistent volume for build (cache) use:"
    echo "docker run --name $CONTAINER_NAME-volume $MOUNT -v /home/jenkins-slave $IMG true"
fi

docker rm -f $CONTAINER_NAME 2>/dev/null # Clean up old builds
docker run $OPTS $NAME $VOLFROM $MOUNT $IMG /bin/bash -c "$SCRIPT"
