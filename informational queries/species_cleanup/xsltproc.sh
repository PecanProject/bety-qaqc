#!/usr/bin/env bash

tmp=/tmp/out.$RANDOM.html

xsltproc -o $tmp summary.xsl duplicate_species_local.xml

open -a 'Google Chrome' $tmp
