\\t

SELECT 'This is a list of sites that are possibly duplicates based on non-unique sitename and geographical proximity.';

\\x

SELECT s.id,
    sitename,
    st_astext(geometry) as "location",
    city,
    state,
    country,
    mat,
    map,
    soil,
    som,
    notes,
    soilnotes,
    greenhouse,
    user_id,
    local_time,
    sand_pct,
    clay_pct,
    (SELECT ARRAY_AGG(citation_id) FROM citations_sites WHERE site_id = s.id) AS "ids of associated citations",
    (SELECT ARRAY_AGG(id) FROM inputs WHERE site_id = s.id) AS "ids of associated inputs",
    (SELECT ARRAY_AGG(id) FROM runs WHERE site_id = s.id) AS "ids of associated runs",
    (SELECT ARRAY_AGG(id) FROM traits WHERE site_id = s.id) AS "ids of associated traits",
    (SELECT ARRAY_AGG(id) FROM workflows WHERE site_id = s.id) AS "ids of associated workflows",
    (SELECT ARRAY_AGG(id) FROM yields WHERE site_id = s.id) AS "ids of associated yields"
FROM
    (SELECT * FROM sites sss
         WHERE %s
             EXISTS(
                 SELECT 1 FROM sites ss
                     WHERE ss.id!=sss.id
                         AND ss.sitename = sss.sitename
                         AND st_dwithin(ss.geometry, sss.geometry, %f/111.0)
                 )
     ) AS s
ORDER BY st_x(st_centroid(s.geometry)),
         st_y(st_centroid(s.geometry)),
         s.sitename;

