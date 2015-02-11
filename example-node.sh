#!/bin/bash

if [[ $(docker info) != *"Kernel Version:"* ]]; then
    echo "Unable to connect with Docker."
    exit 1
fi

PROJECT=docker-builder-pattern
WORKDIR=ui-select

read -r -d '' SCRIPT <<- End
    cd $PROJECT
    Xvfb :1 -ac &
    export DISPLAY=:1

    if [[ ! -d $WORKDIR ]]; then
         git clone https://github.com/angular-ui/ui-select.git $WORKDIR
    fi

    cd $WORKDIR

    npm install -g bower gulp
    npm install --config.interactive=false && bower install --config.interactive=false
    gulp
End

# https://github.com/sirkkalap/jenkins-swarm-slave-nlm-docker
IMG=sirkkalap/jenkins-swarm-slave-nlm:java7
MOUNT="-v $(pwd):/home/jenkins-slave/$PROJECT"
NAME="--name $PROJECT"
OPTS="-it --sig-proxy=true"

VOLFROM=$(docker ps -a | grep -o $PROJECT-volume)
if [ ! -z $VOLFROM ]; then
    VOLFROM="--volumes-from $VOLFROM"
else
    echo "To make persistent volume for build (cache) use:"
    echo "docker run --name $PROJECT-volume $MOUNT -v /home/jenkins-slave $IMG true"
fi

docker rm -f $PROJECT 2>/dev/null # Clean up old builds
docker run $OPTS $NAME $VOLFROM $MOUNT $IMG /bin/bash -c "$SCRIPT"
