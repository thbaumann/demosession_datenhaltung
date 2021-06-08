-- Layer erstellen
DROP TABLE IF EXISTS ausbaucluster;
CREATE TABLE ausbaucluster (
gid serial PRIMARY KEY, 
name varchar ,
description varchar,
geom geometry(MULTIPOLYGON,25832));


-- Funktion erstellen
CREATE OR REPLACE FUNCTION check_overlapping() RETURNS TRIGGER AS
$BODY$
DECLARE
BEGIN
IF TG_OP = 'INSERT'
THEN
IF
(SELECT COUNT(*)
FROM
(SELECT gid
FROM ausbaucluster AS t
WHERE st_overlaps(NEW.geom, t.geom)) AS foo) > 0
THEN
RAISE EXCEPTION 'Speicherung abgebrochen: Ueberlappende Polygone!';
RETURN NULL;
ELSE
RETURN NEW;
END IF;

ELSIF TG_OP = 'UPDATE'
THEN
IF
(SELECT COUNT(*)
FROM
(SELECT gid
FROM ausbaucluster AS t
WHERE st_overlaps(NEW.geom, t.geom)
AND (t.gid <> OLD.gid)) AS foo) > 0
THEN
RAISE EXCEPTION 'Speicherung abgebrochen: Ueberlappende Polygone!';
RETURN NULL;
ELSE RETURN NEW;
END IF;
END IF;
END;
$BODY$
LANGUAGE plpgsql;

-- Trigger erstellen
CREATE TRIGGER check_overlapping_trg
BEFORE INSERT OR UPDATE ON ausbaucluster
FOR EACH ROW EXECUTE PROCEDURE check_overlapping();