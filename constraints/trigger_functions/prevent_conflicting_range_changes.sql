CREATE OR REPLACE FUNCTION prevent_conflicting_range_changes() RETURNS TRIGGER AS $$
    DECLARE name varchar;
    DECLARE min float;
    DECLARE max float;
BEGIN
    SELECT
        min(mean), max(mean) INTO min, max
    FROM
        traits
    WHERE
        NEW.id = traits.variable_id
    GROUP BY
        traits.variable_id;
    IF
        NEW.min::float > min::float
    THEN
        IF
            NEW.max::float < max
        THEN
            RAISE EXCEPTION 'There are traits having values that are greater than % and traits having values that are less than %.', NEW.max, NEW.min;
        ELSE
            RAISE EXCEPTION 'There are traits having values that are less than %.', NEW.min;
        END IF;
    ELSE
        IF
            NEW.max::float < max
        THEN
            RAISE EXCEPTION 'There are traits having values that are greater than % .', NEW.max;
        END IF;
    END IF;        
    RETURN NEW ;
END;
$$ LANGUAGE plpgsql;
