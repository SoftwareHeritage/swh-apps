#!/bin/bash

if [ -e "${SWH_CONFIG_FILENAME}" ]; then
  echo "The config file ${SWH_CONFIG_FILENAME} does not exist."
  exit 1
fi

ENV_VARS="LOGLEVEL STATSD_TAGS OBJECT_TYPE PARTITION_COUNT FIRST_PARTITION LAST_PARTITION"
ERROR=0

for VAR in ${ENV_VARS}; do
    if [ -z "${!VAR}" ]; then
        echo "The ${VAR} environment variable must be set"
        ERROR=1
    fi
done

if [ $ERROR -ne 0 ]; then
    exit 1
fi

echo "Starting scrubber for OBJECT_TYPE=${OBJECT_TYPE} from FIRST_PARTITION=${FIRST_PARTITION} to LAST_PARTITION=${LAST_PARTITION}"
exec swh \
  --log-level $LOGLEVEL \
  scrubber check storage \
  --object-type ${OBJECT_TYPE} \
  --nb-partitions ${NB_PARTITIONS} \
  --start-partition-id ${START_OBJECT} \
  --end-partition-id ${END_OBJECT}
