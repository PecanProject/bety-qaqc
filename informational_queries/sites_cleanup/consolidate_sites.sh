#!/usr/bin/env bash

# This script generates an SQL script for eliminating and consolidating all
# sites that are duplicates of the sites whose ids are listed as script
# arguments.

if [ $# = 0 ]; then
    echo "Usage $0 <id of site row to keep> [<id of site row to keep>...]"
    exit 1
fi

cat < update_references.sql > consolidate_sites.sql

for id in $@; do
    echo "SELECT update_references($id);" >> consolidate_sites.sql
done

echo "DROP FUNCTION update_references(bigint);" >> consolidate_sites.sql

echo "To consolidate references, run"
echo
echo "\tpsql [-U <user>] [-h <host>] <database> < consolidate_sites.sql"
