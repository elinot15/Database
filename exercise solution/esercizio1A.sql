CREATE TABLE theater (
	t_name varchar(50) NOT NULL,
	t_city varchar(50) NOT NULL,
	street varchar(100) NOT NULL,
	civic_number varchar(5) NOT NULL,
	phone varchar(20) NOT NULL,
	email varchar(100) NOT NULL,
	n_seats integer NOT NULL CHECK(n_seats > 0),
	n_parkings integer DEFAULT 0 CHECK(n_parkings >= 0),
	PRIMARY KEY(t_name, t_city)
);


CREATE TABLE projection (
	movie varchar(10) NOT NULL,
	theater_name varchar(50) NOT NULL,
	theater_city varchar(50) NOT NULL,
	p_time timestamp NOT NULL,
	ticket_price numeric(4,2) NOT NULL,
	has_break boolean DEFAULT FALSE,
	PRIMARY KEY(movie, theater_name, theater_city, p_time),
	FOREIGN KEY(theater_name, theater_city) REFERENCES theater(t_name, t_city) ON DELETE CASCADE,
	FOREIGN KEY(movie) REFERENCES movie(id)
);


ALTER TABLE theater ADD COLUMN rest_stop varchar(10) CHECK (rest_stop IN ('bar', 'bistrot', 'restaurant'));


ALTER TABLE theater ADD COLUMN supervisor varchar(16) UNIQUE;

---------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION insert_crew(p_name_par varchar(100), title_par varchar(200), role_par varchar(50), c_name_par varchar(200)) RETURNS BOOLEAN AS $$
DECLARE
movie_id movie.id%TYPE;
person_id person.id%TYPE;

BEGIN

-- if the role does not exist, the insert is canceled 
PERFORM * FROM crew WHERE LOWER(TRIM(p_role)) = LOWER(TRIM(role_par));
IF NOT FOUND THEN
    RAISE NOTICE 'Il ruolo richiesto non è presente nella base di dati. Inserimento annullato.';
    RETURN FALSE;
END IF;

-- get the person_id associated with the p_name_par
SELECT id INTO person_id FROM person WHERE LOWER(TRIM(given_name)) = LOWER(TRIM(p_name_par)) ORDER BY given_name LIMIT 1;
IF person_id IS NULL THEN
    RAISE NOTICE 'Non esistono individui con il nome richiesto. Inserimento annullato.';
    RETURN FALSE;
END IF;

-- get the movie_id associated with the title_par
SELECT id INTO movie_id FROM movie WHERE LOWER(TRIM(official_title))= LOWER(TRIM(title_par)) ORDER BY official_title LIMIT 1;
IF movie_id IS NULL THEN
    RAISE NOTICE 'Non esistono pellicole con il titolo richiesto. Inserimento annullato.';
    RETURN FALSE;
END IF;

-- if arrived here, go with the insert
INSERT INTO crew(person, movie, p_role, character) VALUES(person_id, movie_id, LOWER(TRIM(role_par)), c_name_par);
RETURN TRUE;

EXCEPTION
	WHEN unique_violation THEN
		RAISE NOTICE 'Violazione del vincolo di chiave. Inserimento annullato.';
		RETURN false;

END;
$$ LANGUAGE 'plpgsql';


-- missing person
SELECT * FROM insert_crew('David Carradine', 'Kill Bill: Vol. 3', 'actor', 'Bill');

-- missing movie
SELECT * FROM insert_crew('Uma Thurman', 'Kill Bill: Vol. 4', 'actor', 'The Bride');

-- missing role
SELECT * FROM insert_crew('Uma Thurman', 'Kill Bill: Vol. 3', 'cameramen', null);

-- duplicate key
SELECT * FROM insert_crew('Leonardo DiCaprio', 'Inception', 'actor', 'Cobb');

-- insert ok
SELECT * FROM insert_crew('Uma Thurman', 'Kill Bill: Vol. 3', 'actor', 'The Bride');
