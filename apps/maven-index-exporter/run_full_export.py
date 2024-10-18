# Copyright (C) 2021-2022 The Software Heritage developers
# See the AUTHORS file at the top-level directory of this distribution
# License: GNU General Public License version 3, or any later version
# See top-level LICENSE file for more information

import logging
import click
import sys
import datetime
import glob
import re
from subprocess import check_call, CalledProcessError
from os import chdir, makedirs
from os.path import getsize, isabs, isdir, isfile, join, basename
from pathlib import Path
from shutil import copy2
from urllib.parse import urljoin

import requests

logger = logging.getLogger(__name__)


MAVEN_INDEX_NAME = "nexus-maven-repository-index"
MAVEN_INDEX_ARCHIVE = f"{MAVEN_INDEX_NAME}.gz"


def _download_indexes(base_url: str, work_dir: str) -> None:
    """Download all required indexes from the .index/ directory
    of the specified instance.

    """
    if base_url.startswith('test://'):
        logger.info("(Testing) Fake downloading required indexes")
        return None

    logger.info("Downloading required indexes")

    index_url = urljoin(base_url, ".index/")

    properties_name = f"{MAVEN_INDEX_NAME}.properties"
    properties_file = join(work_dir, properties_name)
    properties_url = urljoin(index_url, properties_name)

    # Retrieve properties file.
    logger.info("  - Downloading %s.", properties_file)
    content = requests.get(properties_url).content.decode()
    open(properties_file, "w").write(content)

    updated = False

    diff_re = re.compile("^nexus.index.incremental-[0-9]+=([0-9]+)")
    for line in content.split("\n"):
        diff_group = diff_re.match(line)
        if diff_group is not None:
            ind_name = f"{MAVEN_INDEX_NAME}.{diff_group.group(1)}.gz"
            ind_path = join(work_dir, ind_name)
            ind_url = urljoin(index_url, ind_name)
            if isfile(ind_path):
                logger.info(
                    "  - File %s exists, skipping download.", basename(ind_path)
                )
            else:
                logger.info(
                    "  - File %s doesn't exist. Downloading file from %s.",
                    basename(ind_path),
                    ind_url,
                )
                # Retrieve incremental gz file
                contentb = requests.get(ind_url).content
                open(ind_path, "wb").write(contentb)
                updated = True

    # Retrieve main index file.
    ind_path = join(work_dir, MAVEN_INDEX_ARCHIVE)
    ind_url = urljoin(index_url, MAVEN_INDEX_ARCHIVE)
    if isfile(ind_path):
        logger.info("  - File %s exists, skipping download.", basename(ind_path))
    else:
        logger.info(
            "  - File %s doesn't exist. Downloading file from %s",
            basename(ind_path),
            ind_url,
        )

        contentb = requests.get(ind_url).content
        open(ind_path, "wb").write(contentb)
        updated = True
    return updated

@click.command()
@click.option(
    "--base-url",
    required=True,
    help=(
        "Base url of the maven repository instance. \n"
        "Example: https://repo.maven.apache.org/maven2/"
    ),
)
@click.option(
    "--work-dir",
    help="Absolute path to the temp directory.",
    default="/tmp/maven-index-exporter/",
)
@click.option(
    "--publish-dir",
    help="Absolute path to the final directory.",
    default="/tmp/maven-index-exporter/publish/",
)
@click.option(
    "--maven-repo",
    help="Maven repository name.",
    default="maven",
)
def main(base_url, work_dir, publish_dir, maven_repo):
    now = datetime.datetime.now()
    work_dir = "/".join((work_dir, maven_repo))
    logger.info("Script: run_full_export")
    logger.info("Timestamp: %s", now.strftime("%Y-%m-%d %H:%M:%S"))
    logger.info("* URL: %s", base_url)
    logger.info("* Working directory: %s", work_dir)
    logger.info("* Publish directory: %s", publish_dir)

    # Check work_dir and create it if needed.
    if isdir(work_dir):
        logger.info("Work_Dir %s exists. Reusing it.", work_dir)
    else:
        try:
            logger.info("Cannot find work_dir %s. Creating it.", work_dir)
            Path(work_dir).mkdir(parents=True, exist_ok=True)
        except OSError as error:
            logger.info("Could not create work_dir %s: %s.", work_dir, error)

    assert isdir(work_dir)
    assert isabs(work_dir)

    # Grab all the indexes
    # Only fetch the new ones, existing files won't be re-downloaded.
    updated = _download_indexes(base_url, work_dir)

    if updated:
        try:
            # Extract indexes into a .fld file to publish
            # this can raise if something is badly wired or something goes wrong
            check_call(["/opt/extract_indexes.sh", work_dir])
        except CalledProcessError as e:
            logger.error(e)
            sys.exit(4)

        logger.info("Export directory has the following files:")
        export_dir = join(work_dir, "export")
        makedirs(export_dir, exist_ok=True)
        chdir(export_dir)
        fld_file = None
        regexp_fld = re.compile(r".*\.fld$")
        for file_ in glob.glob("*.*"):
            logger.info("  - %s size %s", file_, getsize(file_))
            if regexp_fld.match(file_):
                fld_file = file_

        # Now copy the results to the desired location: publish_dir.
        if fld_file and isfile(fld_file):
            logger.info("Found fld file: %s", fld_file)
        else:
            logger.info("Cannot find .fld file. Exiting")
            sys.exit(4)

        makedirs(publish_dir, exist_ok=True)
        publish_file = join(publish_dir, "export-"+maven_repo+".fld")
        logger.info("Copying files to %s.", publish_file)
        try:
            copy2(fld_file, publish_file)
        except OSError as error:
            logger.info("Could not publish results in %s: %s.", publish_dir, error)

    now = datetime.datetime.now()
    logger.info("Script finished on %s", now.strftime("%Y-%m-%d %H:%M:%S"))


###############################################
# Start execution
###############################################

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    main(auto_envvar_prefix='MVN_IDX_EXPORTER')
