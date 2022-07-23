Development Environment
=======================

Neubla Development Environment is based on Docker container and a Git
repository.  Once you clone the repository, you can use it as follows:

    cd <neubla_mlp_downloaded_path>
    export NB_HOME=$PWD
    ./environ/source.sh $NB_HOME

If you encounter the following message, you need to install Docker.

    docker: Cannot connect to the Docker daemon at unix:///var/run/docker.sock.
    Is the docker daemon running?

Whether you are on Linux or macOS, please install docker by referring to the
followings:

- https://docs.docker.com/desktop/mac/install/
- https://docs.docker.com/desktop/linux/install/ubuntu/

Neubla Development Environment currently works on Linux and macOS. It actually
starts a Docker conainter tailored to the development in Neubla. The followings
are the functions that Neubla Development Environment provides:

- compiler
- popular ML frameworks: pytorch, onnx, tensorflow
- de facto standard ML libraries: mmdetection, detectron
- styler
- documentation tool: doxygen
- git
- VS code helper
- vim helper
- cmake
- etc.

Neubla Development Environment has its own version, so if there is an update
in Neubla Development Environment in remote repository, you can sync it up by
just 'git pull'. The update in local machine after 'git pull' is done when
you re-start Neubla Development Environment.

For exiting Neubla Development Environment, just do 'exit'.

## Customization of Neubla Development Environment

If you would like to add packages that can be used inside docker environment, do the following:

* Ubuntu packages (`apt install`): Update `./environ/packages.txt`
* Python packages (`pip3 install`): Update `./environ/requirements.txt`

**Do Not remove or rebuild the existing image** because it may cause a
disruption to other users, e.g., terminating containers being used by others.

If you are adding new packages, please change `NEUBLA_DOCKER_IMAGE_VER` in
`./environ/source.sh` and run `./environ/source.sh` again. The script will
build a new image and start with it. For example, you may set your own version
(or tag) with:

    NEUBLA_DOCKER_IMAGE_VER=1.1.1-john.doe ./environ/source.sh $NB_HOME

Once you are done experimenting, please clean up such experimental images
especially when you are on a shared development server.

## Use VS Code to work with the Neubla's dev server

### Prerequisite

* OpenSSH Client (most Linux-based systems have this)
* VS Code with the [Remote - SSH extension](https://code.visualstudio.com/docs/remote/ssh#_system-requirements)

### Step 1/3. First-time setup

You need to configure your local SSH client to access the server via Teleport Proxy.

On your local computer, login to your Teleport proxy by:

```
tsh login --proxy teleport.corp.neubla.com --user <user_name>
```

Then, you can generate the OpenSSH config for the proxy:

```
tsh config --proxy teleport.corp.neubla.com
```

Append the resulting configuration snippet into your SSH config file located in
`$HOME/.ssh/config` (in Linux or macOS) or `%UserProfile%\.ssh\config` (in Windows)

### Step 2/3. Configure VS Code

Install the Remote - SSH extension if you haven't yet. 

In VS Code, use **Remote-SSH: Connect to Host...** to connect to `dev-02`. Its hostname should be
`dev-02.teleport.corp.neubla.com`. 

Note: If you encounter an error while connecting to the server, you may need to change your VS Code setting:
  - Uncheck "Settings -> Extenstions -> Remote - SSH -> Use Local Server"

### Step 3/3. Use!

* Once connected, in Menu, click **Terminal** -> **New Terminal**. 
* In the terminal, change your current directory to where `neubla-mlp-public` is cloned. 
  (e.g., `cd git/neubla-mlp-public`)
* Start the container: `./environ/source.sh $PWD`

Please see
[Remote Development With Visual Studio Code](https://goteleport.com/docs/server-access/guides/vscode/)
for more information, especially you are working on Microsoft Windows.

## Use Jupyter Notebook

Before run the container, type the following on the server:

	export JUPYTER_PORT=<your_port_number>

After your container is started, start your notebook server as follows:

	jupyter notebook --port=<your_port_number> --ip=0.0.0.0

Open another terminal from your machine and type the following to create a SSH
tunnel between your machine and the notebook server inside the container:
(Here, we assume you have configured VS Code with teleport by following the previous step)

	ssh dev-02.teleport.corp.neubla.com -L 8888:127.0.0.1:<your_port_number>
 
Open your web browser, and go to http://127.0.0.1:8888. 

