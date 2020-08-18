-- si crei un trigger che ricalcola il valore di score quando si modifica la scala di un rating
CREATE OR REPLACE FUNCTION scale_update() RETURNS TRIGGER AS $$
DECLARE
	new_score rating.score%TYPE;
    BEGIN
		IF (OLD.scale <> NEW.scale) THEN
			new_score := OLD.score / OLD.scale * NEW.scale;
			-- attenzione: l'uso di update con clausola AFTER rischia di generare un loop di chiamate
			-- UPDATE rating SET score = new_score WHERE check_date = NEW.check_date AND source = NEW.source AND movie = NEW.movie;
			NEW.score := new_score;
		END IF;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

-- attenzione perché l'uso di AFTER non è efficace. Inoltre, se si usa UPDATE nel trigger si rischia di incorrere in un loop (il confronto OLD.scale <> NEW.scale impedisce l'innesco del loop)
CREATE TRIGGER update_scale_rating BEFORE UPDATE ON rating FOR EACH ROW EXECUTE PROCEDURE scale_update();

UPDATE rating SET scale = 5 WHERE source='unimi';