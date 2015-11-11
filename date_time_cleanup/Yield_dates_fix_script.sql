/*** STEP 1: CHANGING ERRONEOUS OR OBSOLETE DATELOC VALUES ***/

/* Change dateloc 4 (undefined) to 5 (day). */
UPDATE yields SET dateloc = 5 WHERE dateloc = 4;

/* If dateloc is 5.5 (week), round up to 6 (month) and round date to nearest first-of-month */
UPDATE yields SET dateloc = 6, date = date_trunc('month', date + interval '15 days')::date WHERE dateloc = 5.5;
/* NOTE: ALTERNATIVELY, WE COULD DEAL WITH THESE ON A "LAZY" BASIS: THE "Show"
page would show something like "Week of Aug 5, 1978", but if you go in to edit
the entry, the day will not appear; if you then save without filling in the day,
the dateloc will change to 6 (month); if you choose a specific day and then
save, the dateloc will change to 5 (day).  THIS IS THE CURRENT BEHAVIOR! */

/* If dateloc is 6.5 (between month and season), round up to 7 (season) and round date to nearest representative season date (01-01, 04-01, 07-01, or 10-01) */
UPDATE yields SET dateloc = 7, date = date_trunc('quarter', date + interval '46 days')::date WHERE dateloc = 6.5;

/* If dateloc is 7.5 (between season and year), round up to 8 (year) and truncate date to first-of-year */
UPDATE yields SET dateloc = 8, date = date_trunc('year', date)::date WHERE dateloc = 7.5;

/* These were the only aberrant dateloc values in the yields table, so now all dateloc values are in the official set { 5, 6, 7, 8, 9, 95, 96, 97 }. */








/*** STEP 2: DATE NORMALIZATION ***/

/* If date is null and dateloc is 9, set date to the canonical value of 9996-01-01. */
UPDATE yields SET date = '9996-01-01' WHERE date IS NULL AND dateloc = 9;

/* If dateloc is 8, normalize the often-used MM-DD value 06-15 to the canonical value 01-01. */
UPDATE yields SET date = date_trunc('year', date)::date WHERE dateloc = 8 AND extract(month FROM date) = 6 AND extract(day FROM date) = 15;

/* If dateloc is 7, assume entries where day = 1 or day = 15 are OK, but round the date to the nearest representative season date (01-01, 04-01, 07-01, or 10-01) */
UPDATE yields SET date = date_trunc('quarter', date + interval '46 days')::date WHERE dateloc = 7 AND extract(day FROM date) IN (1, 15);

/* If dateloc is 6, assume entries where day = 1 or day = 15 are OK, but normalize to the first of the month. */
UPDATE yields SET date = date_trunc('month', date)::date WHERE dateloc = 7 AND extract(day FROM date) IN (1, 15);






/*** STEP 3: VIEWING PROBLEMATIC CASES ***/

/* Now that we've corrected the easy cases, view the remaining problematic entries. */

/* If dateloc = 9, date should be '9996-01-01'.  Show rows where this is not the case. */
SELECT * FROM yields WHERE dateloc = 9 AND NOT(extract(year FROM date) = 9996 AND extract(month FROM date) = 1 AND extract(day FROM date) = 1);

/* If dateloc = 8, date should be of the form 'YYYY-01-01'. */
SELECT * FROM yields WHERE dateloc = 8 AND NOT(extract(month FROM date) = 1 AND extract(day FROM date) = 1);

/* If dateloc = 7, date should be of the form 'YYYY-01-01', 'YYYY-04-01', 'YYYY-07-01', or 'YYYY-10-01'. */
SELECT * FROM yields WHERE dateloc = 7 AND (extract(month FROM date) NOT IN (1, 4, 7, 10) OR extract(day FROM date) != 1);

/* If dateloc = 6, date should be of the form 'YYYY-MM-01'. */
SELECT * FROM yields WHERE dateloc = 6 AND extract(day FROM date) != 1;

