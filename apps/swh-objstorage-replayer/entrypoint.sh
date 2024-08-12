#!/bin/bash

if [ -z "${SWH_CONFIG_FILENAME}" ]; then
  echo "The SWH_CONFIG_FILENAME environment variable must be set"
  exit 1
fi

if [ ! -e "${SWH_CONFIG_FILENAME}" ]; then
  echo "The config file ${SWH_CONFIG_FILENAME} does not exist"
  exit 1
fi

EXTRA_CLI_OPTIONS=${1-""}
OPTIONS=""

if [ "${CHECK_DST}" == "false" ]; then
  OPTIONS="${OPTIONS} --no-check-dst"
fi

if [ -n "${FETCH_CONCURRENCY}" ]; then
  OPTIONS="${OPTIONS} --concurrency ${FETCH_CONCURRENCY}"
fi

# start the replayer
echo "Starting the content replayer..."
CMD="swh ${EXTRA_CLI_OPTIONS} objstorage replay ${OPTIONS}"
echo "${CMD}"

exec ${CMD}
