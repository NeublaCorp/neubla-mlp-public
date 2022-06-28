Development Environment {#devenv}
=======================

Neubla Development Environment is based on docker container and github. Once
you clone the repository, you can use it as follows:

    cd <neubla_mlp_downloaded_path>
    export NB_HOME=$PWD
    ./environ/source.sh $NB_HOME

If you have the following message, please install Docker.

    docker: Cannot connect to the Docker daemon at unix:///var/run/docker.sock.
    Is the docker daemon running?

Whether you are on Linux or Mac, please install docker by referring to the
followings:

- https://docs.docker.com/desktop/mac/install/
- https://docs.docker.com/desktop/linux/install/ubuntu/

Neubla Development Environment currently works on Linux and Mac. It actually
starts a docker conainter tailored to the development in Neubla. The followings
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

### Customization of Neubal Development Environment

If you would like to add packages that can be used inside docker environment, do the following:

* Ubuntu packages (`apt install`): Update `./environ/packages.txt`
* Python packages (`pip3 install`): Update `./environ/requirements.txt`

**Do Not remove or rebuild the existing image** because it may cause a
disruption to other users, e.g., terminating containers being used by others.

If you are adding new packages, please change `NEUBLA_DOCKER_IMAGE_VER` in
`./environ/source.sh` and run `./environ/source.sh` again. The script will build a new image and start with
it. For example, you may set your own version (or tag) with:

    NEUBLA_DOCKER_IMAGE_VER=1.0.0-john.doe ./environ/source.sh $NB_HOME

Once you are done experimenting, please clean up such experimental images
especially when you are on a shared development server.

#### Use VS Code to work with the Neubla's dev server

Please see [Remote Development With Visual Studio Code](https://goteleport.com/docs/server-access/guides/vscode/)
and follow the steps carefully. 
You will need to change your VS Code setting:
  - uncheck Settings -> Extenstions -> Remote - SSH -> Use Local Server

#### Use Jupyter Notebook

Before run the container, type the following on the server:

	export JUPYTER_PORT=<your_port_number>

After your container is started, start your notebook server as follows:

	jupyter notebook --port=<your_port_number> --ip=0.0.0.0

Open another terminal from your machine and type the following to create a SSH tunnel between your machine and the notebook server inside the container:
(Here we assume you have configured VS Code with teleport by following the previous step)

	ssh dev-02.teleport.corp.neubla.com -L 8888:127.0.0.1:<your_port_number>
 
Open your web browser, and go to http://127.0.0.1:8888. 
