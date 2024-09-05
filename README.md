# Compulab cl-som-imx8 board Yocto Scarthgap (5.0) baseport

## Overview

This Google repo manifest will automatically retrieve sources:
- Yocto Scarthgap 5.0
- Compulab meta-bsp-imx
- linux-imx 6.6.y
- u-boot 2024.4

## Prepare build environment in Windows 11
### Hardware and software requirements
### Installing WSL2
### Installing Win32/Win64 DiskImaginer
### Installing TeraTerm
### Installing Docker

## Perepare build environment in Linux
### Installing Docker


## Building and Running Docker container
Clone docker container and checkout ubuntu.22.04

```sh
git clone https://github.com/a1miro/docker-ubuntu-swbuild.git
git checkout --track origin/ubuntu.22.04
```
set the Docker build environment

```
cd docker-ubuntu-swbuild
./makeenv.sh
```

the **makeenv.sh** shell script sets environment variables are shown below and stores them in .env file
```
uid=1002
gid=1002
username=amironenko
```

this allows sharing of user credentials between the host and the docker container. Start the container build:

```
docker compose build
```

start the container in detached mode (demon)

```
docker compose up -d
```

check the container is running either using docker compose 

``` 
docker compose ps
NAME                   IMAGE                  COMMAND                  SERVICE         CREATED       STATUS      PORTS
swbuild-ubuntu-22.04   swbuild-ubuntu-22.04   "/bin/bash -c '/etc/…"   swbuild-22.04   4 weeks ago   Up 7 days   22/tcp, 0.0.0.0:8024->8024/tcp, :::8024->8024/tcp
```

or by using ***docker ps***

```
docker ps
CONTAINER ID   IMAGE                  COMMAND                  CREATED       STATUS      PORTS                                               NAMES
9c1f9bb4e60b   swbuild-ubuntu-22.04   "/bin/bash -c '/etc/…"   4 weeks ago   Up 7 days   22/tcp, 0.0.0.0:8024->8024/tcp, :::8024->8024/tcp   swbuild-ubuntu-22.04
```

to attach to the running container, again you can either use docker compose command (please notice we use SERVICE field from ***docker compose ps*** command output) here:

```
docker compose -it -u ${USER} swbuild-22.04 /bin/bash
```

or using this docker command (we use *NAMES* field from the ***docker ps*** command output)

```
docker exec -it -u $USER swbuild-ubuntu-22.04 /bin/bash
```

You should get to the docker container bash prompt now 

```
username@swbuild-2204:~$
```



## Retrieve Yocto build environment inside the Docker container 

```sh
git config --global user.email "user.name@gmail.com"
git config --global user.name "User Name"
```

```sh
export PATH=$PATH:/opt/apps/repo
```

```sh
repo init -u https://github.com/a1miro/cl-som-ixm8-manifest.git -b a1miro/scarthgap -m dev.xml --submodules
```

```sh
repo init -u https://github.com/a1miro/cl-som-ixm8-manifest.git -b a1miro/scarthgap -m rel.xml --submodules
```

```sh
repo sync $(($(nproc)*3/4))
```

```sh
repo sync -j$(nproc)
```

## Build Yocto image

```sh
source sources/poky/oe-init-build-env
bitbake -k core-image-base
```

## Using DEBIAN package management for the development build

To inform apt of the repository you want to use, you might create a list file (e.g. my_repo.list) inside the /etc/apt/sources.list.d/ directory. As an example, suppose you are serving packages from a deb/ directory containing the i586, all, and qemux86 databases through an HTTP server named my.server. The list file should contain:

```
deb [trusted=yes] http://example.com/debian buster main
```

```
deb http://my.server/deb/all ./
deb http://my.server/deb/i586 ./
deb http://my.server/deb/qemux86 ./
```


