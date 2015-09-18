/* For the site id value given as argument, this function eliminates other site
rows whose author, year, and title match the given one (provided there would be
no loss of information) and updates references to the eliminated rows to point
to the given one. */

CREATE OR REPLACE FUNCTION update_references(
    kept_site_id bigint
) RETURNS text AS $$
DECLARE
    kept_row RECORD;
    elimination_candidate_row RECORD;
    found_rows_to_eliminate boolean;
    can_delete_row boolean;
    eliminated_site_id int;
    linked_citation_id int;
    link_already_exists int;
BEGIN
    SELECT * FROM sites WHERE id = kept_site_id INTO kept_row;

    IF kept_row IS NULL THEN
        RAISE NOTICE 'The site with id = % doesn''t exist.', kept_site_id;
        EXIT;
    END IF;

    found_rows_to_eliminate := FALSE;
    FOR elimination_candidate_row IN SELECT * FROM sites
            /* Find rows having the same value for the candidate key (author, year, title) that kept_row has ... */
            WHERE sitename = kept_row.sitename
                AND geometry = kept_row.geometry /* require this for now */

                /* ... but that aren't the identical row */
                AND id != kept_site_id

    LOOP

        found_rows_to_eliminate := TRUE;

        /* Ensure we aren't throwing away information we don't already have in kept row. */
        SELECT (elimination_candidate_row.city = '' OR elimination_candidate_row.city = kept_row.city)
            AND (elimination_candidate_row.state = '' OR elimination_candidate_row.state = kept_row.state)
            AND (elimination_candidate_row.country = '' OR elimination_candidate_row.country = kept_row.country)
            AND (elimination_candidate_row.mat IS NULL OR elimination_candidate_row.mat = kept_row.mat)
            AND (elimination_candidate_row.map IS NULL  OR elimination_candidate_row.map = kept_row.map)
            AND (elimination_candidate_row.soil = ''  OR elimination_candidate_row.soil = kept_row.soil)
            AND (elimination_candidate_row.som IS NULL  OR elimination_candidate_row.som = kept_row.som)
            AND (elimination_candidate_row.notes = ''  OR elimination_candidate_row.notes = kept_row.notes)
            AND (elimination_candidate_row.soilnotes = ''  OR elimination_candidate_row.soilnotes = kept_row.soilnotes)
            AND (elimination_candidate_row.greenhouse IS NULL  OR elimination_candidate_row.greenhouse = kept_row.greenhouse)
            AND (elimination_candidate_row.sand_pct IS NULL  OR elimination_candidate_row.sand_pct = kept_row.sand_pct)
            AND (elimination_candidate_row.clay_pct IS NULL  OR elimination_candidate_row.clay_pct = kept_row.clay_pct) INTO can_delete_row;
            -- don't care about local_time, user_id, or timestamps

        IF NOT can_delete_row THEN
            RAISE NOTICE 'Not eliminating row with id = % because it has information the group representative row (whose id is %) does not have.', elimination_candidate_row.id, kept_row.id;
            CONTINUE;
        END IF;

        eliminated_site_id := elimination_candidate_row.id;
        RAISE NOTICE 'Eliminating row with id = %', eliminated_site_id;


        /* Update foreign keys. */

        UPDATE inputs SET site_id = kept_site_id WHERE site_id = eliminated_site_id;
        UPDATE runs SET site_id = kept_site_id WHERE site_id = eliminated_site_id;
        UPDATE traits SET site_id = kept_site_id WHERE site_id = eliminated_site_id;
        UPDATE workflows SET site_id = kept_site_id WHERE site_id = eliminated_site_id;
        UPDATE yields SET site_id = kept_site_id WHERE site_id = eliminated_site_id;


        /* For join tables, the above method might result in duplicates.  Since
        these tables impose uniqueness constraints on the foreign-key pairs, we
        could use the above method if we catch and ignore any uniqueness exceptions.
        Instead, we do the following: */


        FOR linked_citation_id IN SELECT citation_id FROM citations_sites WHERE site_id = eliminated_site_id LOOP

            SELECT COUNT(*) FROM citations_sites WHERE citation_id = linked_citation_id AND site_id = kept_site_id INTO link_already_exists;

            IF link_already_exists = 0 THEN

                UPDATE citations_sites SET site_id = kept_site_id WHERE citation_id = linked_citation_id AND site_id = eliminated_site_id;

            ELSE

                DELETE FROM citations_sites WHERE citation_id = linked_citation_id AND site_id = eliminated_site_id;

            END IF;

        END LOOP;

        DELETE FROM sites WHERE id = eliminated_site_id;

    END LOOP;

    IF NOT found_rows_to_eliminate THEN
        RAISE NOTICE 'There were no site found the are potential duplicates of the site with id = %.  Perhaps you already eliminated them.', kept_site_id;
    END IF;

    RETURN 'DONE';
END
$$ LANGUAGE plpgsql;
