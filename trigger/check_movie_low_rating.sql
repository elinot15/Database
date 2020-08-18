-- check_movie_low_rating
-- Dato un film, restituisce true se esistono rating con valutazione "insufficiente";  false altrimenti. Si intende "insufficiente" la valutazione di un film che è nella metà inferiore dei possibili valori previsti dalla scala. Esempio se la scala è 10, si intende insufficiente una valutazione inferiore a 5 (cioè 10/2)
-- input: il titolo di un film  
-- output: boolean
CREATE OR REPLACE FUNCTION check_movie_low_rating(movie_title varchar(200)) RETURNS boolean AS $$
    BEGIN

    -- se non mi interessa il contenuto del risultato della query è necessario usare il comando PERFORM
	PERFORM * FROM movie AS m WHERE (trim(lower(official_title)) = trim(lower(movie_title))) AND EXISTS (SELECT * FROM rating WHERE (movie = m.id) AND (score < scale/2)); 
	
	IF FOUND THEN
		RETURN true;
	ELSE 
		RETURN false;
	END IF;
	
	END;
$$ LANGUAGE plpgsql;

SELECT * FROM check_movie_low_rating('Inception'); -- false
SELECT * FROM check_movie_low_rating('Il grande attacco'); -- true