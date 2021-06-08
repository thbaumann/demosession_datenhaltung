CREATE VIEW Centroide as
    SELECT gid, st_centroid(geom)::geometry(Point,25832) as geom,name from ausbaucluster;
	
CREATE VIEW puffer as
    SELECT id, rv_bezeichnung, ST_Buffer(geom,5,99)::geometry(Linestring,25832) as geom
from rohrverband;