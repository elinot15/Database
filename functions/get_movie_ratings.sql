-- get_movie_ratings
-- dato un film, restituisce tutti i rating ricevuti
-- input: il titolo di un film
-- output: l'insieme dei rating per il film considerato
CREATE OR REPLACE FUNCTION get_movie_ratings(varchar(200)) RETURNS SETOF rating AS $$
	DECLARE
		a_rating rating%ROWTYPE;
	BEGIN
		FOR a_rating IN SELECT * FROM movie INNER JOIN rating ON movie.id = rating.movie WHERE trim(lower(official_title)) = trim(lower($1))
		LOOP
			RETURN NEXT a_rating;
		END LOOP;		
	END;	
$$ language plpgsql;

SELECT * FROM get_movie_ratings('inception');