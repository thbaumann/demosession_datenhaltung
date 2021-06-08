-- Quelle: https://blog.crunchydata.com/blog/spatial-constraints-with-postgis-in-postgresql-part-3

CREATE TABLE strassen (
  pk bigint PRIMARY KEY,
  name text NOT NULL,
  geom geometry(LineString, 25832) NOT NULL
    CONSTRAINT geom_no_zero_length CHECK (ST_Length(geom) > 0)
    CONSTRAINT geom_no_self_intersection CHECK (ST_IsSimple(geom))
);

CREATE OR REPLACE FUNCTION strassen_knoten_trigger()
  RETURNS trigger AS
  $$
    DECLARE
      c bigint;
    BEGIN

      -- Wie viele andere Strassensegmente beruehrt dieses Segment an seinen Enden? 
	  -- Beruehren (Touch) ist nicht gegeben wenn Segment-Enden andere Segmente abseits derer Vertices beruehren.
	  
	  
      SELECT Count(*)
      INTO c
      FROM strassen
      WHERE ST_Touches(strassen.geom, NEW.geom);

      -- Neue Segmente muessen mindestens ein anderes Segment berühren.
	  
      IF c < 1 THEN
        RAISE EXCEPTION 'Strasse % ist nicht verbunden mit dem Strassennetz', NEW.pk;
      END IF;

      RETURN NEW;
    END;
  $$
  LANGUAGE 'plpgsql';

-- Run for data additions and changes,
-- and allow deferal to end of transaction.
CREATE CONSTRAINT TRIGGER strassen_check 
  AFTER INSERT OR UPDATE ON strassen DEFERRABLE
  FOR EACH ROW EXECUTE FUNCTION strassen_knoten_trigger();