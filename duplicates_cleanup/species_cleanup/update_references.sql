CREATE OR REPLACE FUNCTION update_references(
  kept_species_id bigint
) RETURNS text AS $$
DECLARE
  kept_row RECORD;
  eliminated_row RECORD;
  eliminated_species_id int;
  linked_pft_id int;
  link_already_exists int;
BEGIN
  SELECT * FROM species WHERE id = kept_species_id INTO kept_row;

  FOR eliminated_row IN SELECT * FROM species
      WHERE scientificname = kept_row.scientificname
            AND id != kept_species_id
            AND (genus = '' OR genus = kept_row.genus)
            AND (species = '' OR species = kept_row.species)
            AND (commonname = '' OR commonname = kept_row.commonname)
            AND ("AcceptedSymbol" = '' OR "AcceptedSymbol" = kept_row."AcceptedSymbol")
            AND (spcd IS NULL OR spcd = kept_row.spcd)
            LOOP

    eliminated_species_id := eliminated_row.id;

    RAISE NOTICE 'eliminating row with id = %', eliminated_species_id;

    UPDATE traits SET specie_id = kept_species_id WHERE specie_id = eliminated_species_id;
    UPDATE yields SET specie_id = kept_species_id WHERE specie_id = eliminated_species_id;
    UPDATE cultivars SET specie_id = kept_species_id WHERE specie_id = eliminated_species_id;

    FOR linked_pft_id IN SELECT pft_id FROM pfts_species WHERE specie_id = eliminated_species_id LOOP

      SELECT COUNT(*) FROM pfts_species WHERE pft_id = linked_pft_id AND specie_id = kept_species_id INTO link_already_exists;

      IF link_already_exists = 0 THEN

        UPDATE pfts_species SET specie_id = kept_species_id WHERE pft_id = linked_pft_id AND specie_id = eliminated_species_id;

      ELSE
      
        DELETE FROM pfts_species WHERE pft_id = linked_pft_id AND specie_id = eliminated_species_id;

      END IF;

    END LOOP;

    DELETE FROM species WHERE id = eliminated_species_id;

    END LOOP;
  RETURN 'DONE';
END
$$ LANGUAGE plpgsql;
