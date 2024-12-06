#!/bin/bash

if [ -z "${SWH_CONFIG_FILENAME}" ]; then
  echo "The SWH_CONFIG_FILENAME environment variable must be set"
  exit 1
fi

if [ ! -e "${SWH_CONFIG_FILENAME}" ]; then
  echo "The config file ${SWH_CONFIG_FILENAME} does not exist"
  exit 1
fi

OPTIONS=()

if [ "${CHECK_DST}" == "false" ]; then
  OPTIONS+=("--no-check-dst")
fi

if [ -n "${FETCH_CONCURRENCY}" ]; then
  OPTIONS+=("--concurrency" "${FETCH_CONCURRENCY}")
fi

if [ -n "${STALL_REPORT_FILENAME}" ]; then
  OPTIONS+=("--stall-report-filename" "${STALL_REPORT_FILENAME}")
fi

# start the replayer
echo "Starting the content replayer..."
# word split $SWH_EXTRA_CLI_OPTIONS explicitly
# shellcheck disable=SC2206
CMD=("swh" $SWH_EXTRA_CLI_OPTIONS "objstorage" "replay" "${OPTIONS[@]}" "$@")
echo "${CMD[@]}"

exec "${CMD[@]}"
