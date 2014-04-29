CREATE OR REPLACE FUNCTION restrict_range()
  RETURNS TRIGGER AS $$
BEGIN
  IF COALESCE (
    NEW.mean < (
        SELECT
            CAST (min AS numeric)
        FROM
            variables
        WHERE
            variables.id = NEW.variable_id
    ),
    TRUE
  ) OR COALESCE (
    NEW.mean > (
        SELECT
            CAST (max AS numeric)
        FROM
            variables
        WHERE
            variables.id = NEW.variable_id
    ),
    TRUE
  ) THEN
    raise EXCEPTION 'The value of mean is outside the allowed range for the variable type specified' ;
  END IF;
  RETURN NEW ;
END;
$$ LANGUAGE plpgsql;
