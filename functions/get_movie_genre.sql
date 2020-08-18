-- get_movie_genre
-- Dato un film, restituisce i generi associati
-- input: il titolo di un film
-- output: SETOF di generi associati al film considerato
CREATE OR REPLACE FUNCTION get_movie_genre (varchar(200)) RETURNS SETOF varchar(20) AS $$
    DECLARE
        genre genre.genre%TYPE;
    BEGIN
        FOR genre IN SELECT genre.genre FROM genre INNER JOIN movie ON genre.movie = movie.id WHERE trim(lower(official_title)) = trim(lower($1))
        LOOP
            RETURN NEXT genre;
        END LOOP;
        RETURN;
    END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_movie_genre('inception');