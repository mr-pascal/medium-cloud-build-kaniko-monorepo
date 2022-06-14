# medium-cloud-build-kaniko-monorepo


## Build

```sh

# Build "kaniko-demo" app on your local machine
./build.sh -a kaniko-demo

# Build "kaniko-demo" app on Cloud Build
./build.sh -c -a kaniko-demo

# Run local container in detached mode
docker run -d -p 3000:3000 kaniko-demo

```