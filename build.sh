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

## Env Varianles
#APP=$1 ## e.g. kaniko-demo

## Create dynamic name for the Dockerfile 
DOCKER_FILE=$APP.Dockerfile
## Create dynamic name for the .dockerignore
DOCKER_IGNORE_FILE=$DOCKER_FILE.dockerignore
##

## Copy content from shared Dockerfile to new 
## application specific Dockerfile
cp Dockerfile $DOCKER_FILE

## Create content for .dockerignore file and write it to disk
### *                 -> Ignore everything, we "un-ignore" only explicitly
### !$APP/**          -> Don't ignore anything inside our application folder 
### !$DOCKER_FILE     -> Don't ignore our just created Dockerfile
### **/node_modules   -> Ignore all "node_modules" regardless of the parent folder
### **/dist           -> Ignore all "dist" folders regardless of the parent folder
### **/*.md           -> Ignore all Markdown files
### **/.git           -> Ignore all ".git" folders
### **/.gitignore     -> Ignore all ".gitignore" files
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
        ## When $USE_CLOUD is true, then build via Cloud Build
        echo "Starting build on GCP via Cloud Build..."
        gcloud builds submit --region europe-west2 \
            --config cloudbuild.yaml \
            --ignore-file $DOCKER_IGNORE_FILE \
            --substitutions _DOCKER_FILE=$DOCKER_FILE,_APP=$APP \
            .
    else
        ## If $USE_CLOUD is false or not set, then build
        ## via local Docker 
        echo "Starting local Docker build..."
        docker build -t $APP -f $DOCKER_FILE --build-arg SRC_DIR=$APP . 
fi


## Clean up temporary files
rm $DOCKER_IGNORE_FILE
rm $DOCKER_FILE