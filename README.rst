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
