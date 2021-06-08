-- CREATE EXTENSION POSTGIS;

--drop table rohrverband cascade;

CREATE TABLE rohrverband
(
    id serial PRIMARY KEY,
    rv_bezeichnung text NOT NULL,    -- UNIQUE
    geom geometry(Linestring,25832) NOT NULL CHECK (ST_IsSimple(geom))
    
);

-- Alternativ: ALTER TABLE rohrverband ADD CONSTRAINT rohrverband_pkey PRIMARY KEY (id);

CREATE TABLE rv_bezeichnungen
(
    id serial,
    bezeichnung text NOT NULL,
    CONSTRAINT rv_bez_pkey PRIMARY KEY (bezeichnung)
    
);


ALTER TABLE rohrverband
ADD FOREIGN KEY (rv_bezeichnung) REFERENCES rv_bezeichnungen(bezeichnung); 

ALTER TABLE rohrverband 
   ADD CONSTRAINT check_mikrosegmente CHECK (ST_Length(geom) > 0.5);


--------------
-- etwas kompakter:

CREATE TABLE public.rohrverband
(
    id serial,
    rv_bezeichnung text,
    geom geometry(LineString,25832) NOT NULL,
    CONSTRAINT rohrverband_pkey PRIMARY KEY (id),
    CONSTRAINT rohrverband_rv_bezeichnung_fkey FOREIGN KEY (rv_bezeichnung)
        REFERENCES public.rv_bezeichnungen (bezeichnung) ,
    CONSTRAINT rohrverband_geom_check CHECK (st_issimple(geom)),
    CONSTRAINT check_mikrosegmente CHECK (st_length(geom) > 0.5)
);


---

CREATE TABLE public.projektgebiete
(
    id serial,
    projekt_bezeichnung text,
    geom geometry(Polygon,25832) NOT NULL,
    CONSTRAINT projektgebiete_pkey PRIMARY KEY (id),
    CONSTRAINT projektgebiete_geom_check CHECK (st_isvalid(geom)),
    CONSTRAINT check_polygongroesse CHECK (st_area(geom) > 5)
);





CREATE TABLE public.projektgebiete_generated_always   
(
    id integer primary key generated always as identity,
    projekt_bezeichnung text,
    geom geometry(Polygon,25832) NOT NULL,
    CONSTRAINT projektgebiete_geom_check CHECK (st_isvalid(geom)),
    CONSTRAINT check_polygongroesse CHECK (st_area(geom) > 5)
);

--qgis issue: https://github.com/qgis/QGIS/issues/29560#issuecomment-505371407

-- https://stackoverflow.com/questions/55300370/postgresql-serial-vs-identity


--https://blog.crunchydata.com/blog/spatial-constraints-with-postgis-part-2


