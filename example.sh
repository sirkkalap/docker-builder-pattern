#!/bin/bash

if [[ $(docker info) != *"Kernel Version:"* ]]; then
    echo "Unable to connect with Docker."
    exit 1
fi

OPTS="-it --sig-proxy=true"
PROJECT=ui-select
read -r -d '' SCRIPT <<- End
    git clone https://github.com/angular-ui/ui-select.git $PROJECT
    cd $PROJECT
    npm install -g bower gulp
    npm install && bower install
    gulp
End

# https://github.com/sirkkalap/jenkins-swarm-slave-w-nodejs-docker
IMG=sirkkalap/jenkins-swarm-slave-w-nodejs
MOUNT="-v $(pwd):/home/jenkins-slave/$PROJECT"
NAME="--name $PROJECT"

VOLFROM=$(docker ps -a | grep $PROJECT-volume | cut -d ' ' -f1)
if [ ! -z $VOLFROM ]; then
    VOLFROM="--volumes-from $VOLFROM"
else
    echo "To make persistent volume for build (cache) use:"
    echo "docker run --name $PROJECT-volume -v /home/jenkins-slave ubuntu true"
fi

docker run $OPTS $NAME $VOLFROM $MOUNT $IMG /bin/bash -c "$SCRIPT"

echo "Remember to remove the build container $PROJECT before next build."
echo "For example: docker rm -f $PROJECT"
echo "You may also take a look inside with: docker exec -it $PROJECT bash"
