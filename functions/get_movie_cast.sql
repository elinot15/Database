-- get_movie_cast
-- Dato un film, restituire il cast (le persone che hanno ruolo di attore nel film)
-- input: il titolo di un film
-- output: SETOF person 
CREATE OR REPLACE FUNCTION get_movie_cast(movie_title varchar(200)) RETURNS SETOF person AS $$
    DECLARE
        p person%ROWTYPE;
    BEGIN
        FOR p IN SELECT * FROM person WHERE id IN(SELECT person FROM crew INNER JOIN movie ON crew.movie = movie.id WHERE (trim(lower(official_title)) = trim(lower(movie_title))) AND (p_role = 'actor'))
        LOOP
            RETURN NEXT p;
        END LOOP;
        RETURN;
    END
$$ LANGUAGE plpgsql;

SELECT * FROM get_movie_cast('inception');
SELECT given_name, birth_date, death_date FROM get_movie_cast('inception');


-- get_movie_cast_short
-- Dato un film, restituire given_name, data di nascita e data di morte di ciascun membro del cast (le persone che hanno ruolo di attore nel film)
-- input: il titolo di un film
-- output: SETOF person(given_name, birth_date, death_date)
CREATE TYPE person_short AS (given_name varchar(100), birth_date date, death_date date);
CREATE OR REPLACE FUNCTION get_movie_cast_short(varchar(200)) RETURNS SETOF person_short AS $$
	BEGIN		
		RETURN QUERY SELECT given_name, birth_date, death_date FROM get_movie_cast($1);
	END;
$$ language plpgsql;

SELECT * FROM get_movie_cast_short('inception');