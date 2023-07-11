#!/usr/bin/env bash

##
# File managed by puppet (class profile::jenkins::server), changes will be lost.
##

# Context:
# Called within a jenkins job
# A new commit has been added with a new built docker image application.
# This then tries to tag that commit, and push it to the repository. If it fails
# (because some other job pushed or something), it rebases the commit and tags and push
# again until it successfully pushed

set -x

APPLICATION_TAG=$1
COMMIT_MSG="${APPLICATION_TAG}: Bump new release"
BRANCH="$(git symbolic-ref --quiet HEAD | sed 's|refs/heads/||')"

# do-while...
false; while [ $? -ne 0 ]; do
  git pull --rebase
  git tag -f -a ${APPLICATION_TAG} -m "${COMMIT_MSG}"
  git push origin $BRANCH ${APPLICATION_TAG}
done
