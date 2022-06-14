#!/bin/bash

USE_CLOUD=false

while getopts 'ca:' OPTION; do
  case "$OPTION" in
    c)
        USE_CLOUD=true
      ;;
    a)
      APP=$OPTARG
      ;;
    ?)
      echo "script usage: ./build.sh [-c] -a my-app" >&2
      exit 1
      ;;
  esac
done
shift "$(($OPTIND -1))"

if [[ -z "$APP" ]]; then
    echo "Must provide directory! e.g. ./build.sh -a kaniko-demo" 1>&2

    echo "Script usage: ./build.sh [-c] -a my-app" >&2
    exit 1
fi

if [ ! -d "$APP" ]; then
    echo "Directory '$APP' DOES NOT exists."
    exit 1
fi

## Envs
#APP=$1 ## e.g. kaniko-demo
DOCKER_FILE=$APP.Dockerfile
DOCKER_IGNORE_FILE=$DOCKER_FILE.dockerignore
##

cp Dockerfile $DOCKER_FILE
echo "*
!$APP/**
!$DOCKER_FILE
**/node_modules
**/dist
**/*.md
**/.git
**/.gitignore
" > $DOCKER_IGNORE_FILE


if [ "$USE_CLOUD" = true ] ; 
    then
        echo "Starting build on GCP via Cloud Build..."
        gcloud builds submit --region europe-west2 \
            --config cloudbuild.yaml \
            --ignore-file $DOCKER_IGNORE_FILE \
            --substitutions _DOCKER_FILE=$DOCKER_FILE,_APP=$APP \
            .
    else
        echo "Starting local Docker build..."
        docker build -t $APP -f $DOCKER_FILE --build-arg SRC_DIR=$APP . 
fi


## Clean up temporary files
rm $DOCKER_IGNORE_FILE
rm $DOCKER_FILE