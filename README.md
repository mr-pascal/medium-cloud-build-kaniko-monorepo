# medium-cloud-build-kaniko-monorepo

Run the below commands inside the `kaniko-demo` folder!

## Docker

```sh
# Build
docker build -t nestjs-kaniko -f Dockerfile --build-arg SRC_DIR=kaniko-demo .

# Run container in detached mode
docker run -d -p 3000:3000 nestjs-kaniko

```


## Cloud Build

```sh
# Set GCP project
gcloud config set project <project>
gcloud config set project pascal-sandbox-1112

# Trigger Cloud Build
gcloud builds submit --region <region> --config <path_to_cloudbuild_yaml> <path_to_build_context>
gcloud builds submit --region europe-west2 --config cloudbuild.yaml kaniko-demo

```

```sh
## Additional 2-4 seconds performance boost (35 -> 32s)
"--cache-copy-layers"
```

Temporäres .gcloudignore?

```sh
echo "*
!kaniko-demo
**/node_modules
**/dist
" > .gcloudignore

gcloud builds submit --region europe-west2 --config cloudbuild.yaml .

```




```sh

  - name: 'gcr.io/cloud-builders/gcloud'
    entrypoint: "bash"
    args:
      - "-c"
      - |
          echo "${_DOCKER_FILE} ${_APP}"
          ls -la
          ls -la ${_APP}
          echo "eu.gcr.io/$PROJECT_ID/${_APP}:$COMMIT_SHA"




  - name: 'gcr.io/kaniko-project/executor:latest'
    args:
    - --dockerfile=${_DOCKER_FILE}
    - --cache=true
    - --cache-copy-layers=true
    - --build-arg=SRC_DIR=${_APP}
    - --compressed-caching=false
    - --destination=eu.gcr.io/$PROJECT_ID/${_APP}:$COMMIT_SHA
```