CREATE OR REPLACE FUNCTION restrict_trait_range() RETURNS TRIGGER AS $$
    DECLARE name varchar;
    DECLARE min float;
    DECLARE max float;
BEGIN
    SELECT


        -- If min and max are constrained to be non-null, then the
        -- COALESCE call is not needed.  In this case, some very large
        -- number would be used for unconstrained maximimum values and
        -- some large negative number would be used for unconstrained
        -- minimum values.  Alternatively, the type could be changed
        -- to float so that values '-infinity' and 'infinity' could be
        -- used.  In any case, the min and max columns should probably
        -- at least be altered to some numeric type.

        -- If min, max and mean are all altered to be of the same
        -- type, then the casts will not be needed.
        
        -- Treat NULLs as if they were infinity.        
        variables.name, CAST(COALESCE(variables.min, '-infinity') AS float), CAST(COALESCE(variables.max, 'infinity') AS float) INTO name, min, max
    FROM
        variables
    WHERE
        variables.id = NEW.variable_id;
    IF
        NEW.mean::float < min OR NEW.mean::float > max
    THEN
        RAISE EXCEPTION 'The value of mean for trait % must be between % and %.', name, min::text, max::text;
    END IF;
    RETURN NEW ;
END;
$$ LANGUAGE plpgsql;
