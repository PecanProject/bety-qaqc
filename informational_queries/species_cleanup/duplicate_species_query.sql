SELECT query_to_xml($$

SELECT
	s.*, array_to_string(ARRAY_AGG(DISTINCT t.id), ', ') AS linked_traits,
	array_to_string(ARRAY_AGG(DISTINCT y.id), ', ') AS linked_yields,
	array_to_string(ARRAY_AGG(DISTINCT c.id), ', ') AS linked_cultivars,
	array_to_string(ARRAY_AGG (DISTINCT ps.pft_id), ', ') AS linked_pfts,

    /* Mark for deletion any row such that:
       (A) there are no linked traits, yields, or cultivars;
       (B) there is another row:
           (1)  (a) whose set of linked pfts properly includes this row's set of linked pfts, or
                (b) whose set of linked pfts is equal to this row's set of linked pfts and either:
                    (i) that row has some linked traits, yields, or cultivars; or
                    (ii) that row has a genus value and this one does not; or
                    (iii) that row has a species value and this one does not; or
                    (iv) that row has a commonname value and this one does not; or
                    (v) that row has an AcceptedSymbol value and this one does not; or
                    (vi) that row has an spcd value and this one does not; or
                    (vii) that row has a lower id number than this row;
           (2) whose genus value matches this row if this row's genus value is non-empty;
           (3) whose species value matches this row if this row's species value is non-empty;
           (4) whose commonname value matches this row if this row's commonname value is non-empty;
           (5) whose AcceptedSymbol value matches this row if this row's AcceptedSymbol value is non-empty;
           (6) whose spcd value matches this row if this row's spcd value is non-NULL.

        We may think of the relationship a < b between two rows (here
        referred to as "any row" and "another row") deliniated by the
        above conditions as meaning "a contains less information than
        b, or, if a and b contain the same information, then the id
        number of b is less than that of a".  Moreove, this relation
        imposes a strict partial order on each set of rows sharing the
        same scientificname.  Since only non-maximal elements qualify
        for deletion, it is never the case that all rows in the group
        will be marked for deletion. */
    ((ARRAY_LENGTH(ARRAY_REMOVE(ARRAY_AGG(t.id), NULL), 1) IS NULL) AND -- (A)
    (ARRAY_LENGTH(ARRAY_REMOVE(ARRAY_AGG(y.id), NULL), 1) IS NULL) AND -- (A)
    (ARRAY_LENGTH(ARRAY_REMOVE(ARRAY_AGG(c.id), NULL), 1) IS NULL) AND -- (A)
     (SELECT EXISTS(SELECT 1 FROM species s2 LEFT JOIN pfts_species ps2 ON ps2.specie_id = s2.id
             WHERE s2.scientificname = s.scientificname AND s2.id != s.id GROUP BY s2.id
             HAVING (
                     ARRAY_AGG(DISTINCT ps2.pft_id) @> ARRAY_AGG(DISTINCT ps.pft_id) -- (B1)
                 AND (ARRAY_AGG(DISTINCT ps2.pft_id) != ARRAY_AGG(DISTINCT ps.pft_id) -- (B1a)
                   OR (SELECT COUNT(*) FROM traits WHERE specie_id = s2.id) > 0 -- (B1b i)
                   OR (SELECT COUNT(*) FROM yields WHERE specie_id = s2.id) > 0 -- (B1b i)
                   OR (SELECT COUNT(*) FROM cultivars WHERE specie_id = s2.id) > 0 -- (B1b i)
                   OR (s2.genus != '' AND s.genus = '') -- (B1b ii)
                   OR (s2.species != '' AND s.species = '') -- (B1b iii)
                   OR (s2.commonname != '' AND s.commonname = '') -- (B1b iv)
                   OR (s2."AcceptedSymbol" != '' AND s."AcceptedSymbol" = '') -- (B1b v)
                   OR (s2.spcd IS NOT NULL AND s.spcd IS NULL) -- (B1b vi)
                   OR s2.id < s.id) -- (B1b vii)
                 AND (s.genus = '' OR s2.genus = s.genus) -- (B2)
                 AND (s.species = '' OR s2.species = s.species) -- (B3)
                 AND (s.commonname = '' OR s2.commonname = s.commonname -- (B4))
                 AND (s."AcceptedSymbol" = '' OR s2."AcceptedSymbol" = s."AcceptedSymbol") -- (B5)
                 AND (s.spcd IS NULL OR s2.spcd = s.spcd)) -- (B6)
                    )))) AS can_delete,

    /* Mark as a deletion candidate rows that aren't linked to traits,
    yields, cultivars, or pfts not already linked to some other row.
    In some cases, all rows in a group may be marked as candidates for
    deletion. */
    ((ARRAY_LENGTH(ARRAY_REMOVE(ARRAY_AGG(t.id), NULL), 1) IS NULL) AND
    (ARRAY_LENGTH(ARRAY_REMOVE(ARRAY_AGG(y.id), NULL), 1) IS NULL) AND
    (ARRAY_LENGTH(ARRAY_REMOVE(ARRAY_AGG(c.id), NULL), 1) IS NULL) AND
     (SELECT EXISTS(SELECT 1 FROM species s2 LEFT JOIN pfts_species ps2 ON ps2.specie_id = s2.id
             WHERE s2.scientificname = s.scientificname AND s2.id != s.id GROUP BY s2.id
             HAVING ARRAY_AGG(DISTINCT ps2.pft_id) @> ARRAY_AGG(DISTINCT ps.pft_id)
                    ))) AS deletion_candidate,

    NOT EXISTS(SELECT 1 FROM species s2
    WHERE s2.scientificname = s.scientificname AND s2.id != s.id
    AND
    (s2.genus != '' AND s2.genus != s.genus
    OR s2.species != '' AND s2.species != s.species
    OR s2.commonname != '' AND s2.commonname != s.commonname
    OR s2."AcceptedSymbol" != '' AND s2."AcceptedSymbol" != s."AcceptedSymbol"
    OR s2.spcd IS NOT NULL AND s2.spcd != s.spcd)
    ) AS group_representitive
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
