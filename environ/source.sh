#!/bin/bash
#
# Neubla development environment
#
# Copyright (C) 2022 Neubla Corporation <contact@neubla.com>
#
# Author(s): Minwook Ahn  <minwook.ahn@neubla.com>
#            Kyungho Jeon <kyungho.jeon@neubla.com>
#            Sungwon Lim  <sungwon.lim@neubla.com>
#            Jihun Oh     <oj9040@neubla.com>
#

#
# When you change something, please change the version too.
# We use a versioning scheme similar to [SemVer](https://semver.org/).
# Given a version number MAJOR.MINOR.PATCH, increment the:
# 1. MAJOR version when you make incompatible changes, such as:
#    * removing existing packages from Dockerfile
#    * updating packages that are not backward compatible with
#    * changing the behavior of scripts
# 2. MINOR version when you add something that is backward compatible, such as:
#    * installing a new package or updating existing packages that are backward
#      compatible
# 3. PATCH version when you make backwards compatible bug/style fixes
#

NEUBLA_DOCKER_IMAGE_VER=${NEUBLA_DOCKER_IMAGE_VER:-1.1.1-public}
GCLOUD_VER=${NEUBLA_GCLOUD_VER:-380.0.0}
FLAG_QUIET="--quiet"

# Usage
if [ "$#" -lt "1" ];
then
  echo "Usage: $0 <neubla_mlp_path> [-r|--rebuild]"
  exit 1
else
  if [ ! -d $1 ];
  then
    echo "Error: Directory $1 DOES NOT exists. Please give an absolute path to neubla_mlp"
    exit 1
  fi
  export NB_HOME=$1
fi

echo "### Configuring Neubla Development Environment Version ${NEUBLA_DOCKER_IMAGE_VER}"

git submodule init
git submodule update

# Check os
echo "### Checking Operating System and system configurations..."
unameOut="$(uname -s)"
OS="$(echo ${unameOut} | tr "[:upper:]" "[:lower:]")"
ARCH="$(uname -m)"

echo "### Detected: ${OS} on ${ARCH}"

case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac

# Do you want to rebuild?
flag_rebuild=0
if [ "$#" -gt "1" ];
then
  case "$2" in
    -r|--rebuild)
      flag_rebuild=1
      ;;
    *)
      echo "Error: $2 is not a valid option." >& 2
      echo "Usage: $0 <neubla_mlp_path> [-r|--rebuild]"
      exit 1
      ;;
  esac
fi

# git config
cp ${NB_HOME}/environ/githooks/commit-msg ${NB_HOME}/.git/hooks/
cp ${NB_HOME}/environ/githooks/pre-commit ${NB_HOME}/.git/hooks/
chmod +x ${NB_HOME}/.git/hooks/commit-msg
chmod +x ${NB_HOME}/.git/hooks/pre-commit

# when there is no devenv, build it
environ="unknown"
devenv_exist=0

# Check if the machine includes nvidia gpus
if [ -z "$(command -v nvidia-smi 2> /dev/null)" ]; then
    if [ ${ARCH} = "x86_64" ]; then
      environ="cpu"
      arch="amd64"
    elif [ ${ARCH} = "arm64" ]; then
      environ="cpu"
      arch="arm64"
      ARCH="arm"
    fi
else
    # If you have cuda installed
    environ="cuda"
    echo "### One or more Nvidia GPUs detected..."
    if [ ${ARCH} = "x86_64" ]; then
      arch="amd64"
    elif [ ${ARCH} = "arm64" ]; then
      arch="arm64"
      ARCH="arm"
    else
      echo "### ERROR: Unsupported environment: OS: ${OS}, CPU: ${arc}"
      exit 1
    fi
fi

# Configure container image tag
NEUBLA_DOCKER_IMAGE_NAME=devenv-public-${environ}-${arch}
NEUBLA_DOCKER_IMAGE_TAG=${NEUBLA_DOCKER_IMAGE_VER}

# Check whether the image is available or not
if [ -z "$(docker images --filter=reference="${NEUBLA_DOCKER_IMAGE_NAME}:${NEUBLA_DOCKER_IMAGE_TAG}" -q 2> /dev/null)" ];
then
  devenv_exist=0
else
  devenv_exist=1
fi

# Rebuild image?
if [ ${flag_rebuild} -eq 1 ] || [ ${devenv_exist} -eq 0 ];
then
  # If there exists a "latest" image, untag it since we will build the new latest
  if [ ! -z "$(docker images --filter=reference="${NEUBLA_DOCKER_IMAGE_NAME}:latest" -q 2> /dev/null)" ];
  then
    docker rmi ${NEUBLA_DOCKER_IMAGE_NAME}:latest &> /dev/null
  fi

  # Build!
  echo "### Building a new container images (${NEUBLA_DOCKER_IMAGE_NAME}:${NEUBLA_DOCKER_IMAGE_TAG})..."
  echo "### Please wait with patience. It could take 10-20 minutes..."
  if [ ${environ} = "cuda" ]; then
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb \
	    -O ./cuda-keyring_1.0-1_all.deb --no-verbose
    docker build ${FLAG_QUIET} --platform linux/${arch} \
      -f "$NB_HOME/environ/Dockerfile.${environ}" \
      -t ${NEUBLA_DOCKER_IMAGE_NAME}:${NEUBLA_DOCKER_IMAGE_TAG} . \
      --build-arg USERNAME=$(whoami) --build-arg UID=$(id -u)
    rm -f ./cuda-keyring_1.0-1_all.deb
  else
    docker build ${FLAG_QUIET} --platform linux/${arch} \
      -f "$NB_HOME/environ/Dockerfile.${arch}" \
      -t ${NEUBLA_DOCKER_IMAGE_NAME}:${NEUBLA_DOCKER_IMAGE_TAG} . \
      --build-arg USERNAME=$(whoami) --build-arg UID=$(id -u)
  fi
fi

# Run it!
mkdir -p ${NB_HOME}/configs/ssh
cp -p $HOME/.gitconfig ${NB_HOME}/configs/ 2> /dev/null
cp -p $HOME/.ssh/* ${NB_HOME}/configs/ssh  2> /dev/null

DOCKER_RUN_CMD="${DOCKER_RUN_CMD} --platform linux/${arch} -it --rm"
DOCKER_RUN_CMD="${DOCKER_RUN_CMD} --name $(whoami)-${RANDOM}"
DOCKER_RUN_CMD="${DOCKER_RUN_CMD} -v ${NB_HOME}/..:/workspace/dev"
DOCKER_RUN_CMD="${DOCKER_RUN_CMD} --env USER=$(whoami) --env UID=$(id -u) --env GID=$(id -g)"
DOCKER_RUN_CMD="${DOCKER_RUN_CMD} --env NB_HOME=/workspace/dev/neubla_mlp"
DOCKER_RUN_CMD="${DOCKER_RUN_CMD} --env OS=${OS}"

if [ "$environ" = "cuda" ];
then
  # if we are in devbox, then mount the NAS volume
  echo "### Starting Neubla Development Environment Version ${NEUBLA_DOCKER_IMAGE_VER} with the CUDA enabled..."
  echo  ""
  DOCKER_RUN_CMD="${DOCKER_RUN_CMD} --gpus all -e NVIDIA_DRIVER_CAPABILITIES=compute,utility"
  DOCKER_RUN_CMD="${DOCKER_RUN_CMD} -e NVIDIA_VISIBLE_DEVICES=all"

  # Mount volumes
  if [ -d '/inshared' ];
  then
    DOCKER_RUN_CMD="${DOCKER_RUN_CMD} -v /share:/share --shm-size 8G -v /inshared:/inshared -v /data:/data"
  fi

  # Port mapping
  if [ -v "${JUPYTER_PORT}" ];
  then
    DOCKER_RUN_CMD="${DOCKER_RUN_CMD} -p ${JUPYTER_PORT}:${JUPYTER_PORT}"
  fi

elif [ "$environ" = "cpu" ];
then
  echo "### Starting Neubla Development Environment Version ${NEUBLA_DOCKER_IMAGE_VER}..."
  echo ""
else
  echo "### ERROR: invalid environment ${environ}"
  echo ""
  exit 1
fi

DOCKER_RUN_CMD="${DOCKER_RUN_CMD} ${NEUBLA_DOCKER_IMAGE_NAME}:${NEUBLA_DOCKER_IMAGE_TAG}"
docker run ${DOCKER_RUN_CMD}

rm -rf ${NB_HOME}/configs

exit $?
