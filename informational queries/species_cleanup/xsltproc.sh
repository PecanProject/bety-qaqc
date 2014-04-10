#!/usr/bin/env bash

# draft: psql -At ebi_production_copy < duplicate_species_query.sql > duplicate_species_local.xml

tmp=/tmp/out.$RANDOM.html

xsltproc -o $tmp summary.xsl duplicate_species_local.xml 2> delete_duplicate_species.sql

open -a 'Google Chrome' $tmp
