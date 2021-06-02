# lume-impact-live-demo-docker

Demonstration of LUME-Impact running a live model fetching data from the LCLS EPICS network using Docker containers.

This repository converts the [lume-impact-live-demo](https://github.com/ChristopherMayes/lume-impact-live-demo) application to a Docker image and shows how to run it.

# Building the image

When a tag is pushed to this GitHub repository, a Docker image is automatically built and pushed to Dockerhub using GitHub Actions. The DockerHub repository is [lume-impact-live-demo](https://hub.docker.com/r/tidair/lume-impact-live-demo).

# Run the docker container

Am example [docker-compose.yml](scripts/docker-compose.yml) in provided in this repository. This file defines 2 services:
- The `lume-impact-live-demo` application which runs live models and produce output files,
- A `SFTP` server which allow to access the output files from the `lume-impact-live-demo` service above, as an example on how to access the output data.

Also, the `docker-compose.yml` file defines a data volume where the `lume-impact-live-demo` data is saved. The `SFTP` access the data from this volume as well.
