-- insert_movie_rating
-- Inserisce una tupla di rating dato il titolo di un film e i dati necessari 
-- input: titolo film, source, date, scale, votes, score
-- output: restituisce 0 se l'inserimento è andato a buon fine; 1 se si verifica un errore di chiave primaria duplicata; 2 se si verifica una violazione del vincolo di chiave esterna (movie inserito non esistente); 3 se source o date sono null

--La procedura deve verificare:
-- l’esistenza del film nella tabella movie 
-- il rispetto dei vincoli su rating: source e check_date sono not null
CREATE OR REPLACE FUNCTION insert_movie_rating(movie_title varchar(200), source varchar(200), check_date date, scale numeric, votes integer, score numeric) RETURNS char AS $$
	DECLARE 
		mvID movie.id%TYPE;
	BEGIN		
		
		SELECT id INTO mvID FROM movie WHERE trim(lower(official_title)) = trim(lower(movie_title));
		IF FOUND THEN
			IF (source IS NOT NULL and check_date IS NOT NULL) THEN
				INSERT INTO rating values(check_date, source, mvID, scale, votes, score);
			ELSE
				RAISE INFO 'I campi source e date devono essere diversi da NULL';
				RETURN '3';
			END IF; 			
		ELSE
			RAISE INFO 'Il titolo inserito non esiste. Operazione annullata.';
			RETURN '2';
		END IF;
		
		RETURN '0';
		
		EXCEPTION
		   WHEN unique_violation THEN
		   	   RAISE INFO 'Errore. Si sta inserendo una chiave duplicata (check_date, source, movie)';
			   RETURN '1';
		   WHEN foreign_key_violation THEN
		   	   RAISE INFO E'L\'inserimento ha prodotto una violazione dei vincoli di chiave esterna';
			   RETURN '2';
		
	END;
$$ LANGUAGE plpgsql;

-- per vedere i codici degli errori in consolle
-- \set VERBOSITY 'verbose'
SELECT * FROM insert_movie_rating('Inception', 'unimi', '2018-11-08', 10, 100, 8.9);	
SELECT * FROM insert_movie_rating('Inception', null, '2018-11-08', 10, 100, 8.9);			
SELECT * FROM insert_movie_rating('Nuovo cinema paradiso', 'unimi', '2018-11-08', 10, 100, 8.9);