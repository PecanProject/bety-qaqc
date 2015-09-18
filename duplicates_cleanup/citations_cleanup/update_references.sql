/* For the citation id value given as argument, this function eliminates other
citation rows whose author, year, and title match the given one (provided there
would be no loss of information) and updates references to the eliminated rows
to point to the given one. */

CREATE OR REPLACE FUNCTION update_references(
  kept_citation_id bigint
) RETURNS text AS $$
DECLARE
  kept_row RECORD;
  eliminated_row RECORD;
  eliminated_citation_id int;
  linked_site_id int;
  linked_treatment_id int;
  link_already_exists int;
BEGIN
  SELECT * FROM citations WHERE id = kept_citation_id INTO kept_row;

  FOR eliminated_row IN SELECT * FROM citations

      /* Find rows having the same value for the candidate key (author, year, title) that kept_row has ... */
      WHERE author = kept_row.author
            AND year = kept_row.year
            AND title = kept_row.title

      /* ... but that aren't the identical row */      
            AND id != kept_citation_id

      /* and also ensure we aren't throwing away information we don't already have in kept row. */      
            AND (journal = '' OR journal = kept_row.journal)
            AND (vol IS NULL OR vol = kept_row.vol)
            AND (url = '' OR url = kept_row.url)
            AND (pdf = '' OR pdf = kept_row.pdf)
            AND (doi = ''  OR doi = kept_row.doi)
            LOOP

    eliminated_citation_id := eliminated_row.id;

    RAISE NOTICE 'eliminating row with id = %', eliminated_citation_id;


    /* Update foreign keys. */

    UPDATE managements SET citation_id = kept_citation_id WHERE citation_id = eliminated_citation_id;
    UPDATE methods SET citation_id = kept_citation_id WHERE citation_id = eliminated_citation_id;
    UPDATE priors SET citation_id = kept_citation_id WHERE citation_id = eliminated_citation_id;
    UPDATE traits SET citation_id = kept_citation_id WHERE citation_id = eliminated_citation_id;
    UPDATE yields SET citation_id = kept_citation_id WHERE citation_id = eliminated_citation_id;


    /* For join tables, the above method might result in duplicates.  Since
    these tables impose uniqueness constraints on the foreign-key pairs, we
    could use the above method if we catch and ignore any uniqueness exceptions.
    Instead, we do the following: */

    FOR linked_site_id IN SELECT site_id FROM citations_sites WHERE citation_id = eliminated_citation_id LOOP

      SELECT COUNT(*) FROM citations_sites WHERE site_id = linked_site_id AND citation_id = kept_citation_id INTO link_already_exists;

      IF link_already_exists = 0 THEN

        UPDATE citations_sites SET citation_id = kept_citation_id WHERE site_id = linked_site_id AND citation_id = eliminated_citation_id;

      ELSE
      
        DELETE FROM citations_sites WHERE site_id = linked_site_id AND citation_id = eliminated_citation_id;

      END IF;

    END LOOP;



    FOR linked_treatment_id IN SELECT treatment_id FROM citations_treatments WHERE citation_id = eliminated_citation_id LOOP

      SELECT COUNT(*) FROM citations_treatments WHERE treatment_id = linked_treatment_id AND citation_id = kept_citation_id INTO link_already_exists;

      IF link_already_exists = 0 THEN

        UPDATE citations_treatments SET citation_id = kept_citation_id WHERE treatment_id = linked_treatment_id AND citation_id = eliminated_citation_id;

      ELSE
      
        DELETE FROM citations_treatments WHERE treatment_id = linked_treatment_id AND citation_id = eliminated_citation_id;

      END IF;

    END LOOP;

    DELETE FROM citations WHERE id = eliminated_citation_id;

    END LOOP;
  RETURN 'DONE';
END
$$ LANGUAGE plpgsql;
