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




echo "Total count of missing species referrents:" >> summary_database_statistics
psql $DATABASE < count_missing_species.sql >> summary_database_statistics




echo "Total count of missing treatment referrents:" >> summary_database_statistics
psql $DATABASE < count_missing_treatments.sql >> summary_database_statistics

echo "Missing treatment referrents grouped by citation:" >> summary_database_statistics
psql $DATABASE < count_missing_treatments_by_citation.sql >> summary_database_statistics




echo "Total count of missing cultivar referrents:" >> summary_database_statistics
psql $DATABASE < count_missing_cultivars.sql >> summary_database_statistics

echo "Missing cultivar referrents grouped by citation:" >> summary_database_statistics
psql $DATABASE < count_missing_cultivars_by_citation.sql >> summary_database_statistics

echo "Number of rows where the species associated with the referred-to cultivar does not match the species associated with the row." >> summary_database_statistics
psql $DATABASE < count_cultivar-species_inconsistencies.sql >> summary_database_statistics
