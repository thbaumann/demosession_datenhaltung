--basierend auf https://postgis.net/workshops/postgis-intro/history_tracking.html

CREATE TABLE trassen (
  gid SERIAL PRIMARY KEY,
  id FLOAT8,
  name VARCHAR(200),
  projekt VARCHAR(10),
  typ VARCHAR(50),
  geom GEOMETRY(Linestring,25832)
  );

CREATE TABLE trassen_history (
  hid SERIAL PRIMARY KEY,
  gid INTEGER,
  id FLOAT8,
  name VARCHAR(200),
  projekt VARCHAR(10),
  typ VARCHAR(50),
  geom GEOMETRY(Linestring,25832),
  created TIMESTAMP,
  created_by VARCHAR(32),
  deleted TIMESTAMP,
  deleted_by VARCHAR(32)
);

CREATE OR REPLACE FUNCTION trassen_insert() RETURNS trigger AS
$$
  BEGIN
    INSERT INTO trassen_history
      (gid, id, name, projekt, typ, geom, created, created_by)
    VALUES
      (NEW.gid, NEW.id, NEW.name, NEW.projekt, NEW.typ, NEW.geom,
       current_timestamp, current_user);
    RETURN NEW;
  END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER trassen_insert_trigger
AFTER INSERT ON trassen
  FOR EACH ROW EXECUTE PROCEDURE trassen_insert();
  
CREATE OR REPLACE FUNCTION trassen_delete() RETURNS trigger AS
$$
  BEGIN
    UPDATE trassen_history
      SET deleted = current_timestamp, deleted_by = current_user
      WHERE deleted IS NULL and gid = OLD.gid;
    RETURN NULL;
  END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER trassen_delete_trigger
AFTER DELETE ON trassen
  FOR EACH ROW EXECUTE PROCEDURE trassen_delete();

CREATE OR REPLACE FUNCTION trassen_update() RETURNS trigger AS
$$
  BEGIN

    UPDATE trassen_history
      SET deleted = current_timestamp, deleted_by = current_user
      WHERE deleted IS NULL and gid = OLD.gid;

    INSERT INTO trassen_history
      (gid, id, name, projekt, typ, geom, created, created_by)
    VALUES
      (NEW.gid, NEW.id, NEW.name, NEW.projekt, NEW.typ, NEW.geom,
       current_timestamp, current_user);

    RETURN NEW;

  END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER trassen_update_trigger
AFTER UPDATE ON trassen
  FOR EACH ROW EXECUTE PROCEDURE trassen_update();
  

-- State of history 10 minutes ago
-- Records must have been created at least 10 minute ago and
-- either be visible now (deleted is null) or deleted in the last hour

CREATE OR REPLACE VIEW trassen_letzte_60min AS
  SELECT * FROM trassen_history
    WHERE created < (now() - '60min'::interval)
    AND ( deleted IS NULL OR deleted > (now() - '60min'::interval) );
	
CREATE OR REPLACE VIEW trassen_postgres AS
  SELECT * FROM trassen_history
    WHERE created_by = 'postgres';
	