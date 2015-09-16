#!/usr/bin/env bash

# This script generates and SQL script for eliminating and consolidating all
# citations that are duplicates of the citations whose ids are listed as script
# arguments.

if [ $# = 0 ]; then
    echo "Usage $0 <id of citation row to keep> [<id of citation row to keep>...]"
    exit 1
fi

cat < update_references.sql > consolidate_citations.sql

for id in $@; do
    echo "SELECT update_references($id);" >> consolidate_citations.sql
done

echo "DROP FUNCTION update_references(bigint);" >> consolidate_citations.sql

echo "To consolidate references, run"
echo
echo "\tpsql [-U <user>] [-h <host>] <database> < consolidate_citations.sql"
