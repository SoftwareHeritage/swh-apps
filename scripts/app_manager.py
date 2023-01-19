#!/usr/bin/python3

# Copyright (C) 2022-2023  The Software Heritage developers
# See the AUTHORS file at the top-level directory of this distribution
# License: GNU General Public License v3 or later
# See top-level LICENSE file for more information

"""Cli to manipulate applications (with/without filters), generate/update the
requirements-frozen.txt file for app(s) provided as parameters, list or generate tags,
...

"""

from __future__ import annotations

from collections import defaultdict
import os
from pathlib import Path
import subprocess
import sys
import tempfile
from typing import TYPE_CHECKING, Dict, Iterator, List, Set, Tuple
from venv import EnvBuilder

import click
import yaml

if TYPE_CHECKING:
    from dulwich.repo import Repo

APPS_DIR = Path(__file__).absolute().parent.parent / "apps"

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
        absolute_apps_dirpath = Path(apps_dir)

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


def generate_requirements_frozen(app: str, absolute_apps_dirpath: Path) -> None:
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
            p = Path(f.name)
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


def list_impacted_apps(
    apps_dir: Path, application: str, version: str
) -> Iterator[str]:
    """List all apps whose constraint does not match `application==version.`.

    Expectedly, only applications who have `application` in their
    requirements-frozen.txt have a chance to be listed.

    """
    app_module = from_application_to_module(application)
    version = from_tag_to_version(version)
    for req_file in sorted(apps_dir.glob(f"*/{requirements_frozen}")):
        with open(req_file, "r") as f:
            for line in f:
                line = line.rstrip()
                if "==" in line:  # we ignore the `@` case for now
                    module, version_ = line.rstrip().split("==")
                    if module == app_module:
                        if version == version_:
                            # Application is already built for the right version, stop
                            break
                        # Application has the dependency for another version, rebuild
                        yield req_file.parent.stem


def list_apps(apps_dir: Path) -> Iterator[str]:
    """List all known apps with a requirements.txt file"""
    for req_file in sorted(apps_dir.glob(f"*/{requirements}")):
        yield req_file.parent.stem


@app.command("list")
@click.option(
    "-a", "--application", "application", default=None, help="Application name"
)
@click.option(
    "-v", "--version", "version", default=None, help="Version of the application"
)
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


def compute_information(current_values: Dict):
    """Compute pivot structure as a Dict from the values-swh-application-versions.yaml
    file. The dict has keys a _ separated image name (e.g. swh_vault_cookers, ...).
    The associated value is also dict with key {"image" registry uri, image "version"}
    and their respective value.

    """
    applications_information: Dict[str, Dict[str, str]] = defaultdict(dict)
    for key, value in current_values.items():
        if key.endswith("_image"):
            str_key = key.replace("_image", "")
            applications_information[str_key].update({"image": value})
        elif key.endswith("_image_version"):
            str_key = key.replace("_image_version", "")
            applications_information[str_key].update({"version": value})
    return applications_information


def compute_yaml(updated_information: Dict[str, Dict[str, str]]) -> Dict[str, str]:
    """Computes the yaml dict to serialize in the values...yaml file."""
    yaml_dict = {}
    for image_name, info in updated_information.items():
        if "image" not in info or "version" not in info:
            # FIXME: Those are inconsistent application that will be fixed soon (in
            # charts). See next fixme in `update-values` subcommand.
            continue
        yaml_dict[f"{image_name}_image"] = info["image"]
        yaml_dict[f"{image_name}_image_version"] = info["version"]

    return yaml_dict


def application_tags(repo: Repo, application: Optional[str] = None) -> List[Tuple[str, str, str]]:
    """Returns list of tuple application (tag, date, increment) (from most recent to
    oldest)."""
    import re

    if application:
        pattern = re.compile(
            fr"refs/tags/{re.escape(application)}-(?P<date>[0-9]+)\.(?P<inc>[0-9]+)"
        )
    else:
        pattern = re.compile(
            fr"refs/tags/.*-(?P<date>[0-9]+)\.(?P<inc>[0-9]+)"
        )

    tags = []
    for current_ref in repo.get_refs():
        ref = current_ref.decode()
        is_match = pattern.fullmatch(ref)
        if not is_match:
            continue
        mdata = is_match.groupdict()
        tag = ref.replace("refs/tags/", "")
        tags.append((tag, mdata["date"], mdata["inc"]))

    return sorted(tags, reverse=True)


@app.group("tag")
@click.pass_context
def tag(ctx):
    """Manipulate application tag, for example either determine the last tag or compute
    the next one. Without any parameters this lists the current application tags.

    """
    from dulwich.repo import Repo
    repo_dirpath = ctx.obj["apps_dir"] / '..'

    ctx.obj["repo"] = Repo(repo_dirpath)


@tag.command("list")
@click.argument("application", required=True)
@click.pass_context
def tag_list(ctx, application: str):
    """List all tags for the application provided."""
    repo = ctx.obj["repo"]
    tags = application_tags(repo, application)

    if not tags:
        raise ValueError(f"No tag to display for application '{application}'")

    # else, with no params, just print the application tags
    for tag in tags:
        print(tag[0])


@tag.command("latest")
@click.argument("application", required=True)
@click.pass_context
def tag_latest(ctx, application: str):
    """Determine the latest tag for the application provided."""
    repo = ctx.obj["repo"]
    tags = application_tags(repo, application)

    if not tags:
        raise ValueError(f"No tag to display for application '{application}'")

    # Determine the application's latest tag if any
    print(tags[0][0])


@tag.command("next")
@click.argument("application", required=True)
@click.pass_context
def tag_next(ctx, application: str):
    """Compute the next tag for the application provided."""
    from datetime import datetime, timezone

    repo = ctx.obj["repo"]
    tags = application_tags(repo, application)

    now = datetime.now(tz=timezone.utc)
    current_date = now.strftime("%Y%m%d")
    if tags:
        _, previous_date, previous_tag_date_inc = tags[0]
        inc = int(previous_tag_date_inc) + 1 if current_date == previous_date else 1
    else:
        # First time we ask a tag for that application
        inc = 1

    tag = f"{application}-{current_date}.{inc}"
    print(tag)


def yaml_read(filepath: Path) -> Dict:
    """Read yaml file and returns its data as a Dict."""
    with open(filepath, "r") as f:
        return yaml.safe_load(f)


def yaml_write(filepath: Path, data: Dict) -> None:
    """Read yaml file and returns its data as a Dict."""
    with open(filepath, 'w') as f:
        f.write(yaml.dump(data))


@app.command("update-versions")
@click.option(
    "-a", "--applications-filepath",
    required=True,
    help="Path to the values.yaml file holding the current deployed image versions",
)
@click.option(
    "-c", "--chart-filepath",
    required=True,
    help="Path to the swh-charts:/swh/Charts.yaml",
)
@click.pass_context
def update_values(ctx, applications_filepath: str, chart_filepath) -> None:
    """Update docker image version in swh-charts:/values-swh-application-versions.yaml
    and appVersion in swh-charts:/swh/Chart.yaml.

    This uses the swh-apps' git tags to determine the list of versions to update.

    """

    from dulwich.repo import Repo
    apps_repository_path = ctx.obj["apps_dir"] / '..'
    apps_repository = Repo(apps_repository_path)

    # Read chart application
    chart_information = yaml_read(chart_filepath)
    app_version = int(chart_information['appVersion'])

    # Read application currently deployed
    applications_information = compute_information(yaml_read(applications_filepath))

    # The information to update in the yaml configuration
    updated_information: Dict[str, Dict[str, str]] = {}

    already_treated: Set[str] = set()
    # This reads tags (tags) from the swh-apps repository. Those tags are read in
    # most recent order first (like `git tag -l | sort -r` output). Hence, we treat the
    # first tag of an application, then discards the next occurence (considered
    # too old):
    # <image-name-with-dash>-<release-date>
    # swh-vault-cookers-20221107.1
    # swh-vault-cookers-20220926.2     <- discarded
    # swh-storage-replayer-20221227.1
    # swh-storage-replayer-20220927.1  <- discarded
    # swh-storage-replayer-20220819.1  <- discarded
    for tag, _, _ in application_tags(apps_repository):
        tag_data = tag.split("-")

        # Image name is _ separated in the values.yaml file
        image_name = "_".join(tag_data[:-1])
        image_version = tag_data[-1]

        if image_name in already_treated:
            # Most recent version already treated, we discard the rest
            continue

        already_treated.add(image_name)

        current_info = applications_information[image_name]

        if not current_info:
            # FIXME: Fix the values.yaml to normalize the misnamed application.  Lots of
            # charts to change it immediately, so let's bypass them for now to focus on
            # wiring the automation first.
            print(
                f"Missing or inconsistent information for <{image_name}>"
            )
            continue

        if image_version != current_info["version"]:
            info = {
                "image": current_info["image"],
                "version": image_version,
            }
        else:
            info = current_info

        updated_information[image_name] = info

    # Flush chart update
    chart_information['appVersion'] = app_version + 1
    yaml_write(chart_filepath, chart_information)

    # Flush new application information
    yaml_write(applications_filepath, compute_yaml({
        **applications_information, **updated_information
    }))


if __name__ == "__main__":
    app()
