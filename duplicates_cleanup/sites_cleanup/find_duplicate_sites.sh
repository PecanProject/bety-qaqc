#!/usr/bin/env bash

usage="
Usage:
    $(basename $0) -u|-h|-i
    $(basename $0) [-H host] [-U user] [-d database] [-p port] [-f] [-r <km distance>]
"

help="$usage

    -u            print usage
    -h            print help
    -i            information manual: show complete information about using this script

    -H host       run query on host (default: localhost)
    -p port       PostgreSQL port to connect to (default: 5432)
    -U user       connect to database as user (default: bety)
    -d database   run query against database (default: bety)

    -r distance   maximum distance (in km) allowed between two sites for them to be
                  considered as possible duplicates (default: 0)
    -f            give full information on each site, including list of linked references
    -s            include sites that don't have a sitename
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
    

EOF
}

host=localhost
port=5432
database=bety
user=bety
distance=0
sql_script=subsidiary_scripts/find_duplicate_sites.sql
where_clause="sss.sitename != '' AND"

while getopts 'H:p:d:U:uhir:fs' OPTION
do
    case $OPTION in
        H) host="$OPTARG"
            ;;
        p) port="$OPTARG"
            ;;
        d) database="$OPTARG"
            ;;
        U) user="$OPTARG"
            ;;
        r) distance=$OPTARG
            ;;
        f) sql_script=subsidiary_scripts/find_duplicate_sites_full.sql
            ;;
        s) where_clause=
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

printf "`cat ${sql_script}`" "$where_clause" $distance | psql -d $database -U $user -p $port -h $host
