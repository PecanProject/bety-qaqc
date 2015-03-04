#!/usr/bin/env bash

host=ebi-forecast.igb.illinois.edu
database=ebi_production
user=bety
mode=delete
outfile=delete_duplicate_species.sql

while getopts 'sqh:d:U:m:' OPTION
do
    case $OPTION in
        s) skip_query=1
            ;;
        q) query_only=1
            ;;
        h) host="$OPTARG"
           ;;
        d) database="$OPTARG"
           ;;
        U) user="$OPTARG"
           ;;
        m) mode="$OPTARG"
            ;;
        ?) printf "Usage: %s: [-s]\n" $(basename $0) >&2
            exit 2
            ;;
    esac
done

if [ "$mode" = "consolidate" ]; then
    outfile=consolidate_species.sql
    cat < update_references.sql > $outfile
else
    # truncate outfile:
    echo > $outfile
fi

if [ ! "$skip_query" ]; then

    echo "querying database ..."
    psql -At -U $user -h $host $database < duplicate_species_query.sql > duplicate_species_local.xml
    echo "done"
    echo "After inspecting output, you can run 'psql -U $user -h $host $database < delete_duplicate_species.sql' to eliminate duplicate species rows."

fi

if [ ! "$query_only" ]; then

    tmp=/tmp/out.$RANDOM.html

    echo "processing query output ..."
    xsltproc --stringparam mode "$mode" -o $tmp summary.xsl duplicate_species_local.xml 2>> $outfile || { tail -n1 $outfile; exit 1; }
    echo "done"

    if [ "$mode" = "consolidate" ]; then
        echo "DROP FUNCTION update_references(bigint);" >> $outfile
    fi


    echo "opening browser to result ..."
    open -a 'Google Chrome' $tmp

fi
