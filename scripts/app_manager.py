#!/usr/bin/python3

# Copyright (C) 2022-2023  The Software Heritage developers
# See the AUTHORS file at the top-level directory of this distribution
# License: GNU General Public License v3 or later
# See top-level LICENSE file for more information

"""Cli to list applications (with/without filters) or generate the
requirements-frozen.txt file for app(s) provided as parameters.

"""

import click
import os
import pathlib
import subprocess
import sys
import tempfile
from venv import EnvBuilder
from typing import Iterator


APPS_DIR = pathlib.Path(__file__).absolute().parent.parent / "apps"

# The file to read to determine impacted image to rebuild.
# Note: We cannot use the requirements.txt as it does not explicit the python module it
# depends upon

requirements_frozen = "requirements-frozen.txt"


requirements = "requirements.txt"


@click.group("app")
@click.pass_context
def app(ctx):
    apps_dir = os.environ.get("SWH_APPS_DIR")
    if not apps_dir:
        absolute_apps_dirpath = APPS_DIR
    else:
        absolute_apps_dirpath = pathlib.Path(apps_dir)

    ctx.ensure_object(dict)
    ctx.obj["apps_dir"] = absolute_apps_dirpath


class AppEnvBuilder(EnvBuilder):
    """A virtualenv builder specialized for our usecase"""

    @classmethod
    def bootstrap_venv(cls, directory):
        """Create a clean venv in ``directory``"""

        builder = cls(clear=True, symlinks=True, with_pip=True)

        builder.create(directory)

        return builder

    def post_setup(self, context):
        """Do post-setup operations like upgrade setuptools and pip."""
        super().post_setup(context)

        self.context = context

        self.run_pip("install", "--upgrade", "pip", "setuptools", "wheel")

    def run_pip(self, *args, capture_output=False):
        cmd = [self.context.env_exe, "-m", "pip", *args]

        return subprocess.run(cmd, capture_output=capture_output, check=True)


def generate_requirements_frozen(app: str, absolute_apps_dirpath: pathlib.Path) -> None:
    """Generate the ``requirements-frozen.txt`` file out of the ``requirements.txt``
    file present in the ``app`` directory

    Args:
        app: Name of the application to generate the frozen dependencies set
        absolute_apps_dirpath: Absolute path to folder holding application declarations

    """

    app_dir = absolute_apps_dirpath / app
    src_req_file = app_dir / requirements
    dst_req_file = app_dir / requirements_frozen

    if not src_req_file.is_file():
        raise FileNotFoundError(
            f"{requirements} file for app {app} not found (checked {src_req_file})"
        )

    with tempfile.TemporaryDirectory(prefix=app) as envdir:
        builder = AppEnvBuilder.bootstrap_venv(envdir)

        builder.run_pip("install", "-r", str(src_req_file))
        freeze_output = builder.run_pip("freeze", capture_output=True)

        with tempfile.NamedTemporaryFile(mode="wb", dir=app_dir, delete=False) as f:
            f.write(freeze_output.stdout)
            p = pathlib.Path(f.name)
            p.chmod(0o644)
            p.rename(dst_req_file)


@app.command("generate-frozen-requirements")
@click.argument("applications", required=True)
@click.pass_context
def generate_frozen_requirements(ctx, applications):
    """Generate frozen requirements for applications passed as parameters"""

    absolute_apps_dirpath = ctx.obj["apps_dir"]

    apps = [applications] if isinstance(applications, str) else applications

    for app in apps:
        generate_requirements_frozen(app, absolute_apps_dirpath)


def from_application_to_module(app_name: str) -> str:
    """Compute python module name from the application name."""
    return app_name.replace("-", ".")


def from_tag_to_version(version: str) -> str:
    """Compute python module version from a version tag (prefixed with 'v')."""
    return version.lstrip("v")


def list_impacted_apps(apps_dir: pathlib.Path, application: str, version: str) -> Iterator[str]:
    """List all apps whose constraint does not match `application==version.`.

    Expectedly, only applications who have `application` in their
    requirements-frozen.txt have a chance to be listed.

    """
    app_module = from_application_to_module(application)
    version = from_tag_to_version(version)
    for req_file in sorted(apps_dir.glob(f"*/{requirements_frozen}")):
        with open(req_file, 'r') as f:
            for line in f:
                line = line.rstrip()
                if '==' in line:  # we ignore the `@` case for now
                    module, version_ = line.rstrip().split('==')
                    if module == app_module:
                        if version == version_:
                            # Application is already built for the right version, stop
                            break
                        # Application has the dependency for another version, rebuild
                        yield req_file.parent.stem


def list_apps(apps_dir: pathlib.Path) -> Iterator[str]:
    """List all known apps with a requirements.txt file"""
    for req_file in sorted(apps_dir.glob(f"*/{requirements}")):
        yield req_file.parent.stem


@app.command("list")
@click.option("-a", "--application", "application", default=None, help="Application name")
@click.option("-v", "--version", "version", default=None, help="Version of the application")
@click.pass_context
def list(ctx, application: str, version: str) -> None:
    """With no parameters, list all known applications with a requirements.txt. With
    application and version, list known applications (with requirements.txt) whose
    constraint does not match exactly application & version. Applications without
    constraint  of `application` are ignored.

    """
    absolute_apps_dirpath = ctx.obj["apps_dir"]

    if application is not None and version is not None:
        apps = list_impacted_apps(absolute_apps_dirpath, application, version)
    else:
        apps = list_apps(absolute_apps_dirpath)

    for app in apps:
        print(app)


if __name__ == "__main__":
    app()
