\t

SELECT 'This is a list of sites that are possibly duplicates based on non-unique sitename and geographical proximity.';

\t

SELECT s.id, substring(s.sitename, 1, 51) AS sitename,
    substring(s.city, 1, 11) AS city,
    substring(s.state, 1, 7) AS st,
    substring(s.country, 1, 4) AS ctry,
    st_AStext(s.geometry) AS location
FROM
    (SELECT * FROM sites sss
         WHERE %s
             EXISTS(
                 SELECT 1 FROM sites ss
                     WHERE ss.id!=sss.id
                         AND regexp_replace(ss.sitename, ' *-? *duplicate *', '') = regexp_replace(sss.sitename, ' *-? *duplicate *', '')
                         AND st_dwithin(ss.geometry, sss.geometry, %f/111.0)
                 )
     ) AS s
ORDER BY st_x(st_centroid(s.geometry)),
         st_y(st_centroid(s.geometry)),
         s.sitename;
