#!/usr/bin/env bash

while getopts 'sq' OPTION
do
    case $OPTION in
        s) skip_query=1
            ;;
        q) query_only=1
            ;;
        ?) printf "Usage: %s: [-s]\n" $(basename $0) >&2
            exit 2
            ;;
    esac
done

if [ ! "$skip_query" ]; then

    echo "querying database ..."
    psql -At -U bety -h ebi-forecast.igb.illinois.edu ebi_production < duplicate_species_query.sql > duplicate_species_local.xml
    echo "done"

fi

if [ ! "$query_only" ]; then

    tmp=/tmp/out.$RANDOM.html

    echo "processing query output ..."
    xsltproc -o $tmp summary.xsl duplicate_species_local.xml 2> delete_duplicate_species.sql
    echo "done"

    echo "opening browser to result ..."
    open -a 'Google Chrome' $tmp

fi
