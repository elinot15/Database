-- uso di FOR EACH STATEMENT/ROW
-- si registri in una tabella di notifiche ogni istruzione di aggiornamento sulla tabella movie
CREATE TABLE op_log (
id serial PRIMARY KEY,
op_ts timestamp DEFAULT CURRENT_TIMESTAMP,
description varchar,
affected_table varchar
);

CREATE OR REPLACE FUNCTION log_movie() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO op_log(description, affected_table) VALUES ('update statement', 'movie');
    RETURN NULL;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER movie_update_log AFTER UPDATE ON movie FOR EACH STATEMENT EXECUTE PROCEDURE log_movie();
DROP TRIGGER movie_update_log ON movie;
CREATE TRIGGER movie_update_log BEFORE UPDATE ON movie FOR EACH ROW EXECUTE PROCEDURE log_movie();

UPDATE movie SET length=length*1.05 WHERE year = '2012';