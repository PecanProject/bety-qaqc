CREATE TRIGGER restrict_trait_range
  BEFORE INSERT OR UPDATE ON traits 
  FOR EACH ROW 
EXECUTE PROCEDURE restrict_trait_range();
