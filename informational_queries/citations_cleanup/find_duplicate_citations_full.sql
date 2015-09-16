\x
\t
SELECT 'This is a list of groups of citations having matching author, year, and title';
SELECT 'Some column values displayed in full in expanded mode.';
\t
SELECT c.id, c.author, c.year, c.title,
    c.journal,
    c.vol,
    c.pg,
    c.url,
    c.pdf,
    c.doi,
    c.user_id
FROM
    (SELECT * FROM citations ccc WHERE EXISTS( SELECT 1 FROM citations cc WHERE cc.id!=ccc.id AND cc.author = ccc.author AND cc.year = ccc.year AND cc.title = ccc.title)) AS c
ORDER BY c.author, c.year, c.title, c.id;
