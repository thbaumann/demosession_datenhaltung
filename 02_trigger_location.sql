DROP TABLE IF EXISTS PUBLIC.messungen;

CREATE TABLE PUBLIC.messungen (
gid serial PRIMARY KEY,
name varchar(50), 
gemeinde varchar(50),
date_time timestamp,
geom geometry(POINT,25832));

CREATE INDEX idx_messungen_geom ON public.messungen USING GIST(geom);


CREATE OR REPLACE FUNCTION public.update_messungen()
RETURNS trigger AS $update_messungen$
BEGIN
-- Check ob Name gesetzt
IF NEW.name IS NULL THEN
RAISE EXCEPTION 'Messungen: Name darf nicht leer sein!';
END IF;
-- Name der Gemeinde
-- Testlayer "gemeinde" bezogen von OpenData des LGL: https://www.lgl-bw.de/export/sites/lgl/unsere-themen/Produkte/Open-Data/Galerien/Dokumente/OD_AX_Verwaltungsgebiete_komplett.zip 

NEW.gemeinde = (SELECT gem_nam FROM public.gemeinden
WHERE ST_Within(NEW.geom, geom));
IF NEW.gemeinde IS NULL THEN
RAISE EXCEPTION 'Messungen: Achtung.Messung darf nicht ausserhalb der Gemeinden liegen!';
END IF;
-- Zeitstempel
NEW.date_time := current_timestamp;
RETURN NEW;
END;
$update_messungen$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_messungen ON public.messungen;

CREATE TRIGGER update_messungen BEFORE INSERT OR UPDATE ON
public.messungen
FOR EACH ROW EXECUTE PROCEDURE update_messungen();


-- grundgedanke des beispiels basierend auf https://www.cbs.nl/nl-NL/menu/themas/dossiers/nederland-regionaal/links/2012-wijk-buurtkaart-2011-1-el.htm (Stand 2012,Link heute leider nicht mehr erreichbar)