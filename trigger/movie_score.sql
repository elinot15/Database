-- si crei una vista materializzata che mostri per ogni film il numero di rating ricevuti e lo score complessivo considerando tutti i rating ricevuti (si consideri una scala fino a 10)
CREATE TABLE movie_score (
	movie varchar(10) PRIMARY KEY REFERENCES movie(id) ON UPDATE CASCADE ON DELETE CASCADE,
	rating_number integer,
	score numeric
);

-- popolare la vista materializzata (domanda: è possibile farlo con una query?)
CREATE OR REPLACE FUNCTION populate_movie_score() RETURNS VOID AS $$
DECLARE
	movie_id movie.id%TYPE;
	a_rating rating%ROWTYPE;
	score_value rating.score%TYPE;
	total_votes rating.votes%TYPE;
	total_rating rating.score%TYPE;
	num_rating integer;

BEGIN

-- si tenga presente che possono esistere movie senza alcun rating
FOR movie_id IN SELECT id FROM movie
LOOP
	total_rating := 0;
	total_votes := 0;
	num_rating := 0;
	FOR a_rating IN SELECT * FROM rating WHERE movie = movie_id AND scale <> 0
	LOOP
		total_rating := total_rating + ((a_rating.score / a_rating.scale) * 10) * a_rating.votes;
		total_votes := total_votes + a_rating.votes;
		num_rating := num_rating + 1;
	END LOOP; 
	
	IF total_votes <> 0 THEN
		score_value := total_rating / total_votes;
	ELSE
		score_value := 0;
	END IF;
	
	INSERT INTO movie_score(movie, rating_number, score) VALUES (movie_id, num_rating, score_value);

END LOOP;

RETURN;

END;
$$ language 'plpgsql';

SELECT * FROM populate_movie_score();

-- gestione di insert, update, delete
CREATE OR REPLACE FUNCTION update_movie_score() RETURNS TRIGGER AS $$ 
DECLARE
	movie_id movie.id%TYPE;
	a_rating rating%ROWTYPE;
	score_value rating.score%TYPE;
	total_votes rating.votes%TYPE;
	total_rating rating.score%TYPE;
	num_rating integer;
BEGIN
	
	IF (TG_OP = 'DELETE') THEN
		movie_id := OLD.movie;
	ELSE
		movie_id := NEW.movie;
	END IF;
	
	total_rating := 0;
	total_votes := 0;
	num_rating := 0;
	FOR a_rating IN SELECT * FROM rating WHERE movie = movie_id AND scale <> 0
	LOOP
		total_rating := total_rating + ((a_rating.score / a_rating.scale) * 10) * a_rating.votes;
		total_votes := total_votes + a_rating.votes;
		num_rating := num_rating + 1;
	END LOOP; 
	
	IF total_votes <> 0 THEN
		score_value := total_rating / total_votes;
	ELSE
		score_value := 0;
	END IF;
	
	-- verifico che il movie esista in movie_score
	PERFORM * FROM movie_score WHERE movie = movie_id;
	IF FOUND THEN
		UPDATE movie_score SET score = score_value, rating_number = num_rating WHERE movie = movie_id;
	ELSE
		INSERT INTO movie_score(movie, rating_number, score) VALUES (movie_id, num_rating, score_value);
	END IF;
	
	RETURN NULL;

END;
$$ language 'plpgsql';

-- si verifichi che il trigger non lavora correttamente con la clausola BEFORE
CREATE TRIGGER movie_score_trigger AFTER INSERT OR UPDATE OR DELETE ON rating FOR EACH ROW EXECUTE PROCEDURE update_movie_score();

INSERT INTO rating VALUES (CURRENT_DATE, 'bdlab', '3302820', 5, 50, 2.4);
DELETE FROM rating WHERE check_date = '2018-11-16' AND source = 'bdlab' AND movie ='3302820';
INSERT INTO rating VALUES (CURRENT_DATE, 'bdlab', '1442054', 10, 100, 9.4);
