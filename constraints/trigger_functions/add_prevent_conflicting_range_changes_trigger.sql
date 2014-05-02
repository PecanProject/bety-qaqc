CREATE TRIGGER prevent_conflicting_range_changes
  BEFORE INSERT OR UPDATE ON variables 
  FOR EACH ROW 
EXECUTE PROCEDURE prevent_conflicting_range_changes();
