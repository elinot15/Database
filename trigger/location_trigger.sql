-- su inserimento o modifica di una tupla di location, verificare che
-- -- d_role sia B o D
-- -- la persona non abbia già una tupla con il medesimo d_role

-- verifico che il db sia in stato consistente rispetto a entrambe le richieste
SELECT * FROM location WHERE d_role <> 'B' AND d_role <> 'D';
SELECT person, d_role FROM location GROUP BY person, d_role HAVING count(*) > 1;

-- vincolo per controllare che d_role sia B o D
ALTER TABLE location ADD CONSTRAINT rolecheck CHECK (d_role IN ('B', 'D'));

CREATE OR REPLACE FUNCTION check_person_location() RETURNS TRIGGER AS $$
DECLARE
	the_person person.given_name%TYPE;
BEGIN

	SELECT given_name INTO the_person FROM person WHERE id = NEW.person;
		
	RAISE INFO 'Sto inserendo location per ', the_person || ' tipo ' || NEW.d_role || ' (codice ' || NEW.person || ')';
	
	PERFORM * FROM location WHERE person = NEW.person AND d_role = NEW.d_role;

	IF FOUND THEN 
		-- provare anche 
		-- RAISE EXCEPTION 'Operazione fallita: la persona ha già location per il tipo indicato';
		RAISE INFO 'Operazione fallita: la persona ha già location per il tipo indicato';
		RETURN NULL;
	ELSE
		RETURN NEW;
	END IF;
	
END;
$$ language 'plpgsql';

-- si noti che BEFORE e AFTER producono risultati differenti. Con AFTER la tupla è già inserita e non viene eliminata. Con BEFORE il trigger lavora correttamente
CREATE TRIGGER person_location_trigger AFTER INSERT OR UPDATE ON location FOR EACH ROW EXECUTE PROCEDURE check_person_location();
DROP TRIGGER person_location_trigger ON location;

INSERT INTO location VALUES ('0000138', 'ITA', 'B', 'Hollywood, Los Angeles', 'California');