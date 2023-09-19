#!/bin/bash

set -e

MSG='USAGE_MSG="\e[1;31mBeware of SWH_CONFIG_FILENAME variable !\n
This variable may change according to the context that you use this toolbox.\n
You must define this variable by yourself.\e[m\n\n
\e[0;33mFor example to process add-forge-now request in staging:\e[m\n
export SWH_CONFIG_FILENAME=/etc/swh/config-scheduler-staging.yml\n"'
echo $MSG >> .bashrc
echo 'echo -e $USAGE_MSG' >> .bashrc

echo "Administration purpose pod: connect to it and do what you will!"
while sleep infinity; do :; done
