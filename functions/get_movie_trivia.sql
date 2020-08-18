-- get_movie_trivia
-- Dato un film, restituisce un record con id, titolo del film, genere (concatenare il genere in un'unica stringa se più di uno) e un material casuale di tipo text con description "movie trivia" in lingua inglese (se esiste)
-- input: il titolo di un film 
-- output: record con struttura (movie_id, movie_title, genre, trivia)
CREATE TYPE trivia AS (movie_id varchar(10), movie_title varchar(200), genre text, trivia text);

CREATE OR REPLACE FUNCTION get_movie_trivia(movie_title varchar(200)) RETURNS trivia AS $$
	DECLARE
		t trivia%ROWTYPE;
		
	BEGIN
	
		SELECT id, official_title INTO t.movie_id, t.movie_title FROM movie WHERE trim(lower(official_title)) = trim(lower(movie_title));
		
		SELECT string_agg(genre, ', ') INTO t.genre FROM genre WHERE movie = t.movie_id;
		
		SELECT content INTO t.trivia FROM text INNER JOIN material ON text.material = material.id WHERE (movie = t.movie_id) AND (lang = 'eng') AND (description = 'movie trivia') ORDER BY random() LIMIT 1;

		RETURN t;
		
    END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_movie_trivia('Inception');