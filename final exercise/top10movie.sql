CREATE TYPE topMovie AS (official_title varchar(200), year char(4), 
                                           rating_number integer, score numeric);

CREATE OR REPLACE FUNCTION top10movie()  RETURNS SETOF topMovie AS 
$$ 
  BEGIN
    RETURN QUERY SELECT official_title, year, rating_number, score  
                 FROM movie_score INNER JOIN movie ON movie.id = movie_score.movie 
                 ORDER BY score DESC LIMIT 10;
  END;
$$ language plpgsql;

