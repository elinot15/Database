-- get_movie_card
-- Dato un film, restituire una scheda contenente: titolo, anno e durata del film + lista di paesi in cui il film è stato distribuito con anno e titolo adattato 
-- input: il titolo di un film
-- output: testo della scheda
CREATE OR REPLACE FUNCTION get_movie_card(movie_title varchar(200)) RETURNS text AS $$
    DECLARE
        m movie%ROWTYPE;
        d_country country.name%TYPE;
        d_date released.released%TYPE;
        d_title released.title%TYPE;
        card TEXT;
    BEGIN
        card := '';
        SELECT * INTO m FROM movie WHERE trim(lower(official_title)) = trim(lower(movie_title));
        IF FOUND THEN
			card := m.official_title || ' - ' || m.year || ' (durata:' || m.length || ' minuti)' || E'\n';
			FOR d_country, d_date, d_title IN SELECT country.name, to_char(released.released, 'DD-MM-YYYY'),
			--extract(year from  released.released),
			--released.released, 
			released.title FROM released INNER JOIN country ON released.country = country.iso3 WHERE released.movie = m.id 
			LOOP
				-- attenzione ai valori null: rendono null la stringa
				IF (d_country IS NOT NULL) THEN
					card := card || E'\t' || 'distribuito in ' || d_country;
	
					IF (d_date IS NOT NULL) THEN
						card := card || ' in data ' || d_date;
					END IF;
					
					IF (d_title IS NOT NULL) THEN
						card := card || ' con il titolo ' || d_title;
					END IF;
					
					card := card ||  E'\n';
					
				END IF;
			END LOOP;
	ELSE
			card := 'Il film specificato non esiste';
	END IF;
		
        RETURN card;
    END
$$ LANGUAGE plpgsql;

SELECT * FROM get_movie_card('Inception');
