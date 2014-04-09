#!/usr/bin/env bash

tmp=/tmp/out.$RANDOM.html

xsltproc -o $tmp summary.xsl duplicate_species_local.xml 2> delete_duplicate_species.sql

open -a 'Google Chrome' $tmp
