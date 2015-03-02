SELECT query_to_xml($$

SELECT
	s.*, array_to_string(ARRAY_AGG(DISTINCT t.id), ', ') AS linked_traits,
	array_to_string(ARRAY_AGG(DISTINCT y.id), ', ') AS linked_yields,
	array_to_string(ARRAY_AGG(DISTINCT c.id), ', ') AS linked_cultivars,
	array_to_string(ARRAY_AGG (DISTINCT ps.pft_id), ', ') AS linked_pfts,
    /* Mark for deletion any row such that:
       (1) there are no linked traits, yields, or cultivars;
       (2) there is another row:
           (a)  whose set of linked pfts properly includes this row's set of linked pfts, or
                whose set of linked pfts is equal to this row's set of linked pfts and either that row has some linked traits, yields, or cultivars, or that row has a lower id number than this row;
           (b) whose genus value matches this row if this row's genus value is non-empty;
           (c) whose species value matches this row if this row's species value is non-empty;
           (d) whose commonname value matches this row if this row's commonname value is non-empty;
           (e) whose AcceptedSymbol value matches this row if this row's AcceptedSymbol value is non-empty;
           (f) whose spcd value matches this row if this row's spcd value is non-NULL. */
    ((ARRAY_LENGTH(ARRAY_REMOVE(ARRAY_AGG(t.id), NULL), 1) IS NULL) AND
    (ARRAY_LENGTH(ARRAY_REMOVE(ARRAY_AGG(y.id), NULL), 1) IS NULL) AND
    (ARRAY_LENGTH(ARRAY_REMOVE(ARRAY_AGG(c.id), NULL), 1) IS NULL) AND
     (SELECT EXISTS(SELECT 1 FROM species s2 LEFT JOIN pfts_species ps2 ON ps2.specie_id = s2.id
             WHERE s2.scientificname = s.scientificname AND s2.id != s.id GROUP BY s2.id
             HAVING (
                     ARRAY_AGG(DISTINCT ps2.pft_id) @> ARRAY_AGG(DISTINCT ps.pft_id)
                 AND (ARRAY_AGG(DISTINCT ps2.pft_id) != ARRAY_AGG(DISTINCT ps.pft_id)
                   OR (SELECT COUNT(*) FROM traits WHERE specie_id = s2.id) > 0
                   OR (SELECT COUNT(*) FROM yields WHERE specie_id = s2.id) > 0
                   OR (SELECT COUNT(*) FROM cultivars WHERE specie_id = s2.id) > 0
                   OR s2.id < s.id)
                 AND (s.genus = '' OR s2.genus = s.genus)
                 AND (s.species = '' OR s2.species = s.species)
                 AND (s.commonname = '' OR s2.commonname = s.commonname)
                 AND (s."AcceptedSymbol" = '' OR s2."AcceptedSymbol" = s."AcceptedSymbol")
                 AND (s.spcd IS NULL OR s2.spcd = s.spcd))
                    ))) AS can_delete,
    /* Mark as a deletion candidate rows that satisfy conditions (1) through (2b): */
    ((ARRAY_LENGTH(ARRAY_REMOVE(ARRAY_AGG(t.id), NULL), 1) IS NULL) AND
    (ARRAY_LENGTH(ARRAY_REMOVE(ARRAY_AGG(y.id), NULL), 1) IS NULL) AND
    (ARRAY_LENGTH(ARRAY_REMOVE(ARRAY_AGG(c.id), NULL), 1) IS NULL) AND
     (SELECT EXISTS(SELECT 1 FROM species s2 LEFT JOIN pfts_species ps2 ON ps2.specie_id = s2.id
             WHERE s2.scientificname = s.scientificname AND s2.id != s.id GROUP BY s2.id
             HAVING (
                     ARRAY_AGG(DISTINCT ps2.pft_id) @> ARRAY_AGG(DISTINCT ps.pft_id)
                 AND (ARRAY_AGG(DISTINCT ps2.pft_id) != ARRAY_AGG(DISTINCT ps.pft_id)
                   OR (SELECT COUNT(*) FROM traits WHERE specie_id = s2.id) > 0
                   OR (SELECT COUNT(*) FROM yields WHERE specie_id = s2.id) > 0
                   OR (SELECT COUNT(*) FROM cultivars WHERE specie_id = s2.id) > 0
                   OR s2.id < s.id))
                    ))) AS deletion_candidate
FROM
	species s
LEFT JOIN traits t ON t.specie_id = s.id
LEFT JOIN yields y ON y.specie_id = s.id
LEFT JOIN cultivars c ON c.specie_id = s.id
LEFT JOIN pfts_species ps ON ps.specie_id = s.id
WHERE
	scientificname IN (
		SELECT
			scientificname
		FROM
			species
		GROUP BY
			scientificname
		HAVING
			COUNT(*) > 1
		AND NOT scientificname = ''
		AND scientificname IS NOT NULL
	)
GROUP BY
	s.id
ORDER BY
	scientificname$$,
    'f', -- omit columns containing NULL from output
    'f', -- output as top-level <tablename> element containing <row> elements
    ''); -- empty target namespace
