--drop table linien_notify_test cascade;
CREATE TABLE linien_notify_test
(
    id serial primary KEY,
    name text NOT NULL,    -- UNIQUE
    geom geometry(Linestring,25832)
    
);

-- DROP FUNCTION public.notify_qgis() CASCADE;

CREATE FUNCTION public.notify_qgis()
    RETURNS trigger
    LANGUAGE 'plpgsql'

AS $BODY$ 
        BEGIN NOTIFY qgis, 'refresh lines';
        RETURN NULL;
        END; 
    $BODY$;
   
CREATE TRIGGER notify_qgis_edit 
  AFTER INSERT OR UPDATE OR DELETE 
  ON public.linien_notify_test 
    FOR EACH STATEMENT EXECUTE PROCEDURE public.notify_qgis();
	

