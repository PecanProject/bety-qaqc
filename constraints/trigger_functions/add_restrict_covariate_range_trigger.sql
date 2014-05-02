CREATE TRIGGER restrict_covariate_range
  BEFORE INSERT OR UPDATE ON covariates 
  FOR EACH ROW 
EXECUTE PROCEDURE restrict_covariate_range();
