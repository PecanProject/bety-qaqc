#!/usr/bin/env bash

usage="
Usage:
    $(basename $0) -u|-h|-i
    $(basename $0) [-H host] [-U user] [-d database] [-m (delete|consolidate)]
    $(basename $0) [-H host] [-U user] [-d database] -q
    $(basename $0) -s [-m (delete|consolidate)]
"

help="$usage

	-u		print usage
	-h		print help
	-i		information manual: show complete information about using this script

	-H host		run query on host (default: localhost)
	-U user		connect to database as user (default: bety)
	-d database	run query against database (default: bety)
	-m mode		mode can be either 'delete' (the default) or 'consolidate'

	-q		run the SQL query only; don't generate the HTML file or a deletion or
	      		consolidation script
	-s		skip the running of the SQL query (This assumes it's output, the file
	      		duplicate_species_local.xml, already exists.)
"

usage() {
    echo "$usage"
}

help() {
    echo "$help"
}

man() {
    less <<EOF
$help
    
    This script produces an HTML page showing information about duplicate
    species rows and how to eliminate or consolidate them.

    The protocol for using this script is as follows:

    1. Run the script in 'delete' mode as follows:

        $(basename $0) [-H host] [-U user] [-d database]

    This will produce an HTML file, save it to the /tmp directory, and attempt
    to open the saved file in a browser.  Examine this file.  The rows scheduled
    for deletion are marked in red.  A row qualifies for deletion only if some
    other row contains the same or more information than it does.  More
    specifically, it quallifies for deletion if and only if there are no traits,
    yields, or cultivars that refer to it and there is some other row such that

        a. for each of the columns "genus", "species", "commonname",
        "AcceptedSymbol" and "spcd" that is non-null and non-empty, the value is
        the same as in that other row;

        b. every PFT it belongs to also includes that other row.

    In addition, if that other row has no traits, yields, or cultivars that
    refer to it and contains exactly the same information with regard to
    "genus", "species", "commonname", "AcceptedSymbol" and "spcd", then that
    other row must have a lower id number.  (In other words, if two rows are the
    same in regards to all of the information we care about, we choose to keep
    the one with the lower id number.)

    In addition, an SQL script file 'delete_duplicate_species.sql' for carrying
    out the scheduled deletions will be produced.

    2. If the scheduled deletions seem reasonable, run the deletion script:

        psql -H host -U user -d database < delete_duplicate_species.sql

    (Use the same host and database as before, of course.)

    3. Run this script again, this time in consolidation mode:

        $(basename $0) [-H host] [-U user] [-d database] -m consolidate

    Again, this will produce an HTML file.  This time, there should be no rows
    sceduled for deletion.  (If this script is run in consolidation mode
    prematurely, when there are still obvious candidates for deletion, the
    script will abort with a message saying to first run it in deletion mode.)

    Instead, certain rows may be marked (in green) as representitive rows for
    the group of rows having the same scientificname value.  This means the
    other rows may be consolidated into it by updating references and then
    deleted with no resulting loss of information.  More specifically, a row
    qualifies as a representitive row if, for every other row in its group, each
    of the columns "genus", "species", "commonname", "AcceptedSymbol" and "spcd"
    that is non-null and non-empty has the same value as the representive row.

    Running this script in consolidate mode will produce an SQL script file
    'consolidate_species.sql'.  Running it will, for each group that has a
    representitive row, eliminate all the other rows in the group after updating
    the references in those other rows.

    4. If the scheduled consolidations seem reasonable, run the consolidation
    script:

        psql -H host -U user -d database < consolidate_species.sql

    (Again, use the same host and database as in the previous steps.)

    5. Re-run this script.  (The mode used shouldn't matter.)  Groups that
    remain have two or more rows with differing (non-empty, non-null)
    information in one or more of the columns "genus", "species", "commonname",
    "AcceptedSymbol" or "spcd".  These differences will have to be reconciled
    manually, after which this script can be run again.

    In cases where a row could be deleted once information in one or more of the
    columns "genus", "species", "commonname", "AcceptedSymbol" or "spcd" is
    reconciled (with no need to update or consolidate references), it is marked
    as a candidate for deletion (in orange-gold).  Once the information is
    reconciled, the row will be marked for deletion (in red) the next time this
    script is run in delete mode.

    On the other hand, if information needs to be reconciled both with regards
    to references and with regards to information contained in the species table
    proper, it may be that none of the rows in a group get marked.
EOF
}

host=localhost
database=bety
user=bety
mode=delete
outfile=delete_duplicate_species.sql

while getopts 'sqH:d:U:m:uhi' OPTION
do
    case $OPTION in
        s) skip_query=1
            ;;
        q) query_only=1
            ;;
        H) host="$OPTARG"
           ;;
        d) database="$OPTARG"
           ;;
        U) user="$OPTARG"
           ;;
        m) mode="$OPTARG"
            ;;
        u) usage
            exit
            ;;
        h) help
            exit
            ;;
        i) man
            exit
            ;;
        ?) usage
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
