#!/usr/bin/env bash

. connection_variables

PSQL="psql -h $HOST -U $USER $DATABASE"

echo "RESULTS" > summary_database_statistics
echo >> summary_database_statistics


echo "Total number of traits and yields rows:" >> summary_database_statistics
$PSQL -c "SELECT COUNT(*) FROM traits_and_yields_view_private" >> summary_database_statistics




echo "Number of missing citations in traits and yields tables:" >> summary_database_statistics 
$PSQL < count_missing_citations.sql >> summary_database_statistics

echo "Here are some details about the data connected with the missing citations:" >> summary_database_statistics 
$PSQL < identify_missing_citations.sql >> summary_database_statistics




echo "Total count of missing site referrents:" >> summary_database_statistics
$PSQL < count_missing_sites.sql >> summary_database_statistics

echo "Missing site referrents grouped by citation:" >> summary_database_statistics
$PSQL < count_missing_sites_by_citation.sql >> summary_database_statistics




echo "Total count of missing species referrents:" >> summary_database_statistics
$PSQL < count_missing_species.sql >> summary_database_statistics




echo "Total count of missing treatment referrents:" >> summary_database_statistics
$PSQL < count_missing_treatments.sql >> summary_database_statistics

echo "Missing treatment referrents grouped by citation:" >> summary_database_statistics
$PSQL < count_missing_treatments_by_citation.sql >> summary_database_statistics




echo "Total count of missing cultivar referrents:" >> summary_database_statistics
$PSQL < count_missing_cultivars.sql >> summary_database_statistics

echo "Missing cultivar referrents grouped by citation:" >> summary_database_statistics
$PSQL < count_missing_cultivars_by_citation.sql >> summary_database_statistics

echo "Number of rows where the species associated with the referred-to cultivar does not match the species associated with the row." >> summary_database_statistics
$PSQL < count_cultivar-species_inconsistencies.sql >> summary_database_statistics
