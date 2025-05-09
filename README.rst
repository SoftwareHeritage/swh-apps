Software Heritage virtual environment packaging manifests
=========================================================

This repository contains the manifests and scripts to automate the packaging of
SWH applications into (fairly) reproducible Python virtual environments, and
then onto container images.

Problem statement
-----------------

To move away from our legacy Debian-based packaging and deployment workflow, we
are using Python virtual environments to generate (fairly) reproducible
deployment environments, that would be consistent between:

 - docker-based local environments
 - "bare VM/Metal" deployments (on Debian systems still managed by puppet)
 - elastic deployments based on k8s
 - CI environments used for testing packages

We want the input for generating these environments to be declarative (for
instance, "I want an environment with ``swh.provenance``"), and the resulting
environments to be:

 - frozen (using a consistent, known set of package versions)
 - kept up to date automatically (for our swh packages, as well as the external
   dependencies)
 - tested before publication (at least to a minimal extent, e.g. ensuring that
   the tests of the declared input modules are successful before tagging an
   application as ready to deploy)

Packaging Workflow
------------------

Each standalone application is generated from an input ``requirements.txt``
file. Out of this, a virtualenv is generated and frozen into a
``requirements-frozen.txt`` file, which is then used to build container images
(when associated with a ``Dockerfile`` and an entry point script).

The frozen requirements file can also be used to deploy virtual environments
directly, e.g. on an existing VM or bare metal server.

Local development
-----------------

App-manager
~~~~~~~~~~~

It's the cli tools which allows to execute various actions:
- list dependency between swh modules
- manipulate the generation of frozen requirements for our python applications
- helm chart dependency version update
- etc...

.. code::

   # Build the app-manager image
   docker build -t app-manager scripts

List dependent applications
~~~~~~~~~~~~~~~~~~~~~~~~~~~

This is the listing command to list whatever other applications is depending
on a specification application version.

.. code::

   docker run --rm -v $workspace/swh-apps:/src \
     app-manager list-dependent-apps \
       --application swh.graph --version v6.3.0

Example:

.. code::

   docker run --rm -v $workspace/swh-apps:/src \
     app-manager list-dependent-apps \
       --application swh.graph --version v6.3.0
   swh-alter
   swh-graph
   swh-provenance
   swh-vault-cookers
   swh-web


Freeze application dependencies
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This is in charge of using the existing requirements.txt declared besides the
application's Dockerfile and generate an updated frozen-requirements.txt. This
file is then used within the docker image to build an identical python
environments within the image.

Note that it does update any dependencies within the environments so any new
upstream libraries will get updated if new releases happened.

.. code::

   docker run --rm -v $workspace/swh-apps:/src \
     app-manager generate-frozen-requirements swh-provenance

.. code::

   $ docker run --rm -v $workspace/swh-apps:/src \
       app-manager generate-frozen-requirements swh-provenance
   Collecting uv
     Downloading uv-0.5.26-py3-none-manylinux_2_17_x86_64.manylinux2014_x86_64.whl (16.2 MB)
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 16.2/16.2 MB 36.4 MB/s eta 0:00:00
   Installing collected packages: uv
   Successfully installed uv-0.5.26

   [notice] A new release of pip is available: 23.0.1 -> 25.0
   [notice] To update, run: python3 -m pip install --upgrade pip
   Using Python 3.10.15 environment at: /tmp/swh-provenancep16_3kh7
   Resolved 3 packages in 46ms
   Prepared 3 packages in 86ms
   Uninstalled 2 packages in 51ms
   Installed 3 packages in 32ms
    - pip==23.0.1
    + pip==25.0
    - setuptools==65.5.0
    + setuptools==75.8.0
    + wheel==0.45.1
   # This file was autogenerated by uv via the following command:
   #    uv pip compile /src/apps/swh-provenance/requirements.txt -o /src/apps/swh-provenance/tmpk6i4m4rz
   Resolved 76 packages in 850ms
   aiohappyeyeballs==2.4.4
       # via aiohttp
       # via -r /src/apps/swh-provenance/requirements.txt
   python-magic==0.4.27
       # via swh-core
   python-mimeparse==2.0.0
       # via aiohttp-utils
   pyyaml==6.0.2
       # via swh-core
   redis==5.2.1
       # via
       # via -r /src/apps/swh-provenance/requirements.txt
   ...
   swh-storage==2.9.0
       # via
       #   swh-dataset
       #   swh-provenance
   tenacity==9.0.0
       # via
       #   swh-core
       #   swh-journal
       #   swh-storage
   tqdm==4.67.1
       # via swh-dataset
   types-protobuf==5.29.1.20241207
       # via mypy-protobuf
   types-requests==2.32.0.20241016
       # via swh-dataset
   typing-extensions==4.12.2
       # via
       #   multidict
       #   swh-core
       #   swh-model
       #   swh-objstorage
       #   swh-storage
   urllib3==2.3.0
       # via
       #   botocore
       #   requests
       #   sentry-sdk
       #   types-requests
   werkzeug==3.1.3
       # via flask
   wrapt==1.17.2
       # via deprecated
   yarl==1.18.3
       # via aiohttp

Update swh-charts' version
~~~~~~~~~~~~~~~~~~~~~~~~~~

Providing access to both the swh-apps and the swh-charts repositories, this
allows to update the values of values-swh-application-versions.yaml with the
most recent docker image versions. This also bumps the Charts.yaml's version
incrementally.

.. code::

   docker run --rm \
     --volume $workspace/swh-apps:/src \
     --volume $workspace/swh-charts:/tmp/swh-charts \
     app-manager update-versions \
       --applications-filepath /tmp/s-charts/values-swh-application-versions.yaml \
       --chart-filepath /tmp/swh-charts/swh/Chart.yaml

Build application image
~~~~~~~~~~~~~~~~~~~~~~~

Each application is stored in swh-apps:/apps/$application_dir/ folder.
It usually holds the same set of files:
- Dockerfile: The set of instructions to build the application's docker image
- entrypoint.sh: The last Dockerfile instruction refers to this executable to run in the
    image.
- requirements.txt: The set of python dependencies the application requires to run.
- requirements-frozen.txt: The derivative frozen set of dependencies to reproduce the
    environment in the docker image. It's built by the app-manager out of the
    requirements.txt file.

Cli call to build the application locally:

.. code::

   $ DOCKER_BUILDKIT=1 docker build -t swh-toolbox:latest apps/swh-toolbox \
     --build-arg REGISTRY=

Note: The REGISTRY is empty so we only rely to local docker image. You can avoid
changing it, in which case, it will use the swh's gitlab registry.

Cli call to run the application and be dropped in a shell:

.. code::

   $ docker run -it swh-toolbox:latest shell

Note: This is specific command depending on the entrypoint.sh. In that case, the
entrypoint.sh allows a shell option to be dropped in an interactive bash session.
