#!/bin/bash

# Set Env Vars
HOME=/home/$USER

# Configure user-specifics
if [ ${OS} = "darwin" ]; then
  # If you're using Mac (darwin), your effective GID will be 20 (staff)
  # But in Ubuntu Linux, 20 is the GID assigned to dialup
  # Thus, if the host is Mac, then use 1006 as the user's effective GID
  groupadd -g 1006 developers
  useradd -u $UID -g 1006 -m -s /bin/bash $USER
  usermod -aG sudo $USER
else
  groupadd -g $GID $USER
  groupadd -g 1006 developers
  useradd -u $UID -g $USER -m -s /bin/bash $USER
  usermod -aG sudo $USER
  usermod -aG developers $USER
fi

echo PATH="$HOME/.local/bin:/usr/local/cmake/bin:${PATH}" >> $HOME/.bashrc
echo PS1=\"\(neubla\) \\u\@\\w \" >> $HOME/.bashrc
echo "cd /workspace/dev" >> $HOME/.bashrc
echo "export NB_HOME=${NB_HOME}" >> $HOME/.bashrc
# https://developer.nvidia.com/blog/cuda-pro-tip-understand-fat-binaries-jit-caching/
echo "export CUDA_CACHE_DISABLE=1" >> $HOME/.bashrc

echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Copy gitconfig from the host
cp -p ${NB_HOME}/configs/.gitconfig $HOME/.gitconfig

# Configure ssh
mkdir -p $HOME/.ssh

chmod 700 $HOME/.ssh
cp -p ${NB_HOME}/configs/ssh/* $HOME/.ssh/

if [ ${OS} = "darwin" ]; then
  chown -R ${UID}:1006 $HOME/.ssh
else
  chown -R ${UID}:${GID} $HOME/.ssh
fi

# Clean-up
rm -rf ${NB_HOME}/configs/

sudo su - $USER
