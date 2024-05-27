#!/bin/bash

if [ -z "${SWH_CONFIG_FILENAME}" ]; then
  echo "The SWH_CONFIG_FILENAME environment variable must be set"
  exit 1
fi

if [ ! -e "${SWH_CONFIG_FILENAME}" ]; then
  echo "The config file ${SWH_CONFIG_FILENAME} does not exist"
  exit 1
fi

echo "Starting loader metadata journal client..."
exec swh \
  metadata-loader \
  --config-file $SWH_CONFIG_FILENAME \
  journal-client $SWH_INDEXER_TYPE
