create table backbone
(gid serial PRIMARY KEY, betroffene_gemeinden varchar, geom
geometry(LINESTRING,25832));

CREATE OR REPLACE FUNCTION topology_fields()
RETURNS trigger AS
$$
BEGIN
SELECT string_agg(gemeinden.gem_nam,', ')
INTO NEW.betroffene_gemeinden
FROM gemeinden
                  -- Testlayer "gemeinde" bezogen von OpenData des LGL: https://www.lgl-bw.de/export/sites/lgl/unsere-themen/Produkte/Open-Data/Galerien/Dokumente/OD_AX_Verwaltungsgebiete_komplett.zip 
WHERE ST_Intersects(NEW.geom, gemeinden.geom);
RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';

CREATE TRIGGER fill_topology_fields
BEFORE INSERT OR UPDATE ON backbone
FOR EACH ROW EXECUTE PROCEDURE topology_fields();

-- basierend auf: https://gis.stackexchange.com/a/49289 
