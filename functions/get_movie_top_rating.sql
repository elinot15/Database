-- get_movie_top_rating
-- Dato un film, restituisce il rating più alto (score) ricevuto
-- input: il titolo di un film
-- output: lo score più alto per il film considerato
CREATE OR REPLACE FUNCTION get_movie_top_rating (varchar(200)) RETURNS numeric AS $$
    DECLARE
        top_rating rating.score%TYPE;
    BEGIN
        SELECT max(score) INTO top_rating FROM movie INNER JOIN rating ON movie.id = rating.movie WHERE trim(lower(official_title)) = trim(lower($1));
        RETURN top_rating;
    END;
$$ LANGUAGE plpgsql;

-- verificare il funzionamento con trailing blanks e differenti capital letters
SELECT * FROM get_movie_top_rating('inception');


-- get_movie_top_rating_cursor
-- Analoga a get_movie_top_rating con uso di cursore (senza uso di max
-- input: il titolo di un film
-- output: lo score più alto per il film considerato
CREATE OR REPLACE FUNCTION get_movie_top_rating_cursor (varchar(200)) RETURNS numeric AS $$
    DECLARE
        top_rating rating.score%TYPE;
        a_rating rating.score%TYPE;
        movie_ratings CURSOR FOR SELECT score FROM movie INNER JOIN rating ON movie.id = rating.movie WHERE trim(lower(official_title)) = trim(lower($1));
        
    BEGIN
    	OPEN movie_ratings;
    	top_rating := -1;
    	
    	LOOP
    		FETCH movie_ratings INTO a_rating;
    		EXIT WHEN NOT FOUND;
    		
    		IF a_rating IS NOT NULL THEN
    			IF a_rating > top_rating THEN
    				top_rating := a_rating;
    			END IF;
    		END IF;        
        END LOOP;
        CLOSE movie_ratings;
        RETURN top_rating;
    END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_movie_top_rating_cursor('inception');