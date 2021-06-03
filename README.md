# lume-impact-live-demo-docker

Demonstration of LUME-Impact running a live model fetching data from the LCLS EPICS network using Docker containers.

This repository converts the [lume-impact-live-demo](https://github.com/ChristopherMayes/lume-impact-live-demo) application to a Docker image and shows how to run it.

# Directory structure

This repository has two main directories:
- [docker](docker): is the Docker image context, and contains all the files needed to build the Docker image, including the [Dockerfile](docker/Dockerfile), and
- [scripts](scripts): contains example scripts on how to run the Docker container.

# Building the image

When a tag is pushed to this GitHub repository, a Docker image is automatically built and pushed to Dockerhub using GitHub Actions. The DockerHub repository is [lume-impact-live-demo](https://hub.docker.com/r/tidair/lume-impact-live-demo).

## Source code

The Docker image needs two github repositories:
- [lume-impact-live-demo](https://github.com/ChristopherMayes/lume-impact-live-demo): this is a public repository and it is cloned in the [Dockerfile](docker/Dockerfile), and
- [lcls-lattice](https://github.com/slaclab/lcls-lattice): this is private repository and it is cloned in the Github Action script inside the [docker](docker) directory; the [Dockerfile](docker/Dockerfile) copies it to the Docker image from there.

**Note:** If you want to build this image manually, you will need to provide a copy of the [lcls-lattice](https://github.com/slaclab/lcls-lattice) in the [docker](docker) directory.

# Run the docker container

## Using `docker-compose`:

Am example [docker-compose.yml](scripts/docker-compose.yml) in provided in this repository. This file defines 2 services:
- The `lume-impact-live-demo` application which runs live models and produce output files,
- A `SFTP` server which allow to access the output files from the `lume-impact-live-demo` service above, as an example on how to access the output data.

Also, the `docker-compose.yml` file defines a data volume where the `lume-impact-live-demo` data is saved. The `SFTP` access the data from this volume as well.

## Running only the Docker container:

If you want to only run the Docker container, you need to provide a local directory in your host for the output data of the `lume-impact-live-demo` application, and mount it in the container as `/output`. Otherwise you won't be able to access the generated data.

Moreover, the output directory must contain the sub-directories `archive`, `plot`, and `output`.

So, assuming that you want to use the output directory `${PWD}/output` in your host, you will first create the directory structure:
```bash
$ mkdir -p output/{plot,archive,output}

```

and then you can start the container with a command like this:
```bash
$ docker container run -ti --rm \
	--name lume-test \
	--mount type=bind,source="$(pwd)"/output,target=/output \
	tidair/lume-impact-live-demo:v0.0.0
```

**Note:** If your user is not part of the `docker` group, you will need to run this command with `root` privileges (for example, using `sudo`).
