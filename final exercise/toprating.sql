CREATE TYPE topRat AS (data date, sorgente varchar(200), titolo  varchar(200), 
                                    scala numeric, voti integer, score_n numeric);
CREATE OR REPLACE FUNCTION topRatings(k integer)  RETURNS SETOF topRat AS 
$$ 
  BEGIN
    RETURN QUERY SELECT check_date, source, official_title, scale, votes, 
                                                         score/scale as score_n 
    					FROM rating INNER JOIN movie ON movie.id = rating.movie	 
    					ORDER BY score_n DESC limit k;
  END;
$$ language plpgsql;

-----------------------------------------------------------------------
scritta da me non è soluzione 

CREATE OR REPLACE FUNCTION maggiore_zero() RETURNS boolean AS $$
BEGIN 
   perform *from rating where scale=0;
   IF FOUND
   RETURN false;
   ELSE 
    RETURN TRUE;
END;
$$ 
language pgplsql;




ALTER TABLE rating 
ADD CONSTRAINT maggiore ON rating CHECK(rating>0);
---------------------------------------------------------------------

