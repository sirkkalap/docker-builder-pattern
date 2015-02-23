#!/bin/bash

if [[ $(docker info) != *"Kernel Version:"* ]]; then
    echo "Unable to connect with Docker."
    exit 1
fi

PROJECT=ui-select
CONTAINER_NAME=ui-select-build

read -r -d '' SCRIPT <<- End
	sudo apt-get -y install imagemagick
    cd $PROJECT
    sudo Xvfb :1 -ac &
    export DISPLAY=:1
    google-chrome about:blank &
    firefox about:blank &
    sleep 3
    import -window root -display :1 -screen 0.png
    exit 1

    sudo npm install -g bower gulp
    sudo npm install && bower install
    sudo gulp
End

# https://github.com/sirkkalap/jenkins-swarm-slave-nlm-docker
IMG=sirkkalap/jenkins-swarm-slave-nlm
MOUNT="-v $(pwd)/$PROJECT:/home/jenkins-slave/$PROJECT"
NAME="--name $CONTAINER_NAME"
OPTS="-it --sig-proxy=true"

docker rm -f $CONTAINER_NAME 2>/dev/null # Clean up old builds
docker run $OPTS $NAME $VOLFROM $MOUNT $IMG /bin/bash -c "$SCRIPT"
