#!/usr/bin/env bash

# Modify as needed:
DATABASE=ebi_production_copy


echo "RESULTS" > summary_database_statistics
echo >> summary_database_statistics

echo "Total number of traits and yields rows:" >> summary_database_statistics
psql -c "SELECT COUNT(*) FROM traits_and_yields_view_private" $DATABASE >> summary_database_statistics

echo "Number of missing citations in traits and yields tables:" >> summary_database_statistics 
psql $DATABASE < count_missing_citations.sql >> summary_database_statistics


echo "Here are some details about the data connected with the missing citations:" >> summary_database_statistics 
psql $DATABASE < identify_missing_citations.sql >> summary_database_statistics

echo "Total count of missing site referrents:" >> summary_database_statistics
psql $DATABASE < count_missing_sites.sql >> summary_database_statistics


echo "Missing site referrents grouped by citation:" >> summary_database_statistics
psql $DATABASE < count_missing_sites_by_citation.sql >> summary_database_statistics
