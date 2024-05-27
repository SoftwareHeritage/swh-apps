#!/bin/bash

if [ -z "${SWH_CONFIG_FILENAME}" ]; then
  echo "The SWH_CONFIG_FILENAME environment variable must be set"
  exit 1
fi

if [ -z "${SWH_INDEXER_TYPE}" ]; then
  echo "The SWH_INDEXER_TYPE environment variable must be set"
  exit 1
fi

if [ ! -e "${SWH_CONFIG_FILENAME}" ]; then
  echo "The config file ${SWH_CONFIG_FILENAME} does not exist"
  exit 1
fi

# start the replayer
echo "Starting indexer journal client..."
exec swh \
  --log-level azure.core.pipeline.policies.http_logging_policy:WARNING \
  indexer \
  --config-file $SWH_CONFIG_FILENAME \
  journal-client $SWH_INDEXER_TYPE
