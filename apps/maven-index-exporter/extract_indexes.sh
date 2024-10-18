#!/bin/bash

# Copyright (C) 2021-2022 The Software Heritage developers
# See the AUTHORS file at the top-level directory of this distribution
# License: GNU General Public License version 3, or any later version
# See top-level LICENSE file for more information

WORKDIR=${1-/work}
FILE_IN="$WORKDIR/nexus-maven-repository-index.gz"

localtime=$(date +"%F %T %Z%z")
echo "Docker Script started on $localtime."
echo "# Checks.."

echo "* Content of /opt:"
ls -l /opt
echo "* Content of $WORKDIR:"
ls -l "$WORKDIR"

echo "* Will read files from [$FILE_IN]."

if [ ! -r "$FILE_IN" ]; then
    exit_code=4
    echo "Cannot find file [$FILE_IN]."
    echo "Need an index file to work on. Exiting ${exit_code}."
    exit $exit_code
else
    echo "*   Found file [$FILE_IN]."
fi

indexer=$(find /opt/ -name "indexer-cli-*.jar")
if [ "$indexer" = "" ]; then
    exit_code=6
    echo "Cannot find indexer. Exiting ${exit_code}."
    exit $exit_code
else
    echo "*   Found indexer [$indexer]."
fi

clue=$(find /opt/ -name "clue-*.jar")
if [ "$clue" = "" ]; then
    exit_code=8
    echo "Cannot find clue. Exiting ${exit_code}."
    exit $exit_code
else
    echo "*   Found clue [$clue]."
fi

echo "* Java version:."
java -version

echo "#############################"

if [ -d "$WORKDIR"/indexes ]; then
    echo "Found $WORKDIR/indexes, skipping index generation."
    du -sh "$WORKDIR/indexes/"
else
    echo "Unpacking [$FILE_IN] to $WORKDIR/indexes"
    java --illegal-access=permit -jar "$indexer" \
        --index "$WORKDIR" \
        --unpack "$FILE_IN" \
        --destination "$WORKDIR/indexes/" \
        --type full 2>&1 | grep -v WARNING
fi

localtime=$(date +"%F %T %Z%z")
echo "Unpacking finished on $localtime."

echo "#############################"
EXPORT_DIR="$WORKDIR/export/"
[[ -d "$EXPORT_DIR" ]] || mkdir "$EXPORT_DIR"
TEMP_FLD=$(find "$EXPORT_DIR" -name "*.fld")
TEMP_FLD_LOCK=$(find "$EXPORT_DIR" -name "*.lock")

if [[ -f $TEMP_FLD && -f $TEMP_FLD_LOCK ]]; then
    exit_code=1
    echo "Found exported file $TEMP_FLD. Another process is updating it. Stopping."
    exit $exit_code
elif [[ -f $TEMP_FLD && ! -f $TEMP_FLD_LOCK ]]; then
    echo "Found final exported file $TEMP_FLD, skipping index export."
    ls -lh "$EXPORT_DIR"
else
    echo "Exporting indexes $WORKDIR/indexes to $WORKDIR/export"
    java --illegal-access=permit -jar "$clue" \
         "$WORKDIR/indexes/" \
         export "$EXPORT_DIR" text 2>&1 | grep -v WARNING
fi

localtime=$(date +"%F %T %Z%z")
echo "Exporting finished on $localtime."

echo "#############################"

echo "Cleaning useless files."

echo "Size before cleaning:"
du -sh "$WORKDIR"/*

# We might want or not to delete the indexes
# Remember that when they're not present, everything
# gets recomputed every run..
# echo "* Removing indexes."
# rm -rf $WORKDIR/indexes/

# If files others than the .fld one are required, please comment
# the following lines.
echo "* Removing useless exports."
echo "  Keeping only fld text extract."
rm -f "$EXPORT_DIR"/*.inf
rm -f "$EXPORT_DIR"/*.len
rm -f "$EXPORT_DIR"/*.pst
rm -f "$EXPORT_DIR"/*.si
rm -f "$EXPORT_DIR"/segments*
rm -f "$EXPORT_DIR"/*.lock

echo "  Size after cleaning:"
du -sh "$WORKDIR"/*

echo "* Make files modifiable by the end-user."
chmod -R 777 "$EXPORT_DIR"
chmod -R 777 "$WORKDIR/indexes/"

localtime=$(date +"%F %T %Z%z")
echo "Docker Script execution finished on $localtime."

exit 0
