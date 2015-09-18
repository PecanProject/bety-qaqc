\t
SELECT 'This is a list of groups of citations having matching author, year, and title.';
SELECT 'Some column values are truncated so that rows display on a single line.';
\t
SELECT c.id, c.author, c.year, SUBSTRING(c.title, 1, 10) AS "title",
    SUBSTRING(c.journal, 1, 10) AS "journal",
    c.vol, c.pg,
    SUBSTRING(c.url, 1, 10) AS "url",
    SUBSTRING(c.pdf, 1, 10) AS "pdf",
    SUBSTRING(c.doi, 1, 10) AS "doi",
    c.user_id
FROM
    (SELECT * FROM citations ccc WHERE EXISTS( SELECT 1 FROM citations cc WHERE cc.id!=ccc.id AND cc.author = ccc.author AND cc.year = ccc.year AND cc.title = ccc.title)) AS c
ORDER BY c.author, c.year, c.title, c.id;
