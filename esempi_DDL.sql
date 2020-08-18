-- IMDB SCHEMA
-- COUNTRY(iso3, name)
-- MOVIE(id, official_title, budget*, year, length, plot*)
-- PERSON(id, bio, first_name, last_name, birth_date, death_date*)
-- GENRE(movie, genre)
-- CREW(person, movie, p_role, character*)
-- LOCATION(person, country, d_role, city, region)
-- RATING(source, movie, check_date, scale, score, votes)
-- PRODUCED(movie, country)
-- RELEASED(movie, country, released, title)
-- SIM(movie1, movie2, cause, score)
-- MATERIAL(id, description, language, movie)
-- MULTIMEDIA(material, url, type, runtime*, resolution*)
-- TEXT(material, content)

-- * uso di vincoli: PRIMARY KEY, NOT NULL, UNIQUE, DEFAULT
CREATE TABLE country (
    iso3 char(3) PRIMARY KEY,
    name varchar(20) NOT NULL
);

INSERT INTO country(iso3, name) VALUES ('USA', 'United States');
INSERT INTO country(iso3, name) VALUES ('ITA', 'Italy');
INSERT INTO country(iso3, name) VALUES ('FRA', 'France');
INSERT INTO country(iso3, name) VALUES ('GBR', 'United Kingdom');

-- esempi con i tipi di dato char e varchar
INSERT INTO country(iso3, name) VALUES ('DEUS', 'Germany - Deutschland'); -- entrambi i valori eccedono la dimensione massima del campo
INSERT INTO country(iso3, name) VALUES ('PR', 'Portugal');
INSERT INTO country(iso3, name) VALUES ('PR ', 'Portugal '); -- si notino i caratteri blank in coda al valore
-- Le seguenti operazioni hanno il medesimo risultato? Quale impatto producono i blank finali di una stringa char e varchar?
SELECT * FROM country WHERE iso3 = 'PR';
SELECT * FROM country WHERE iso3 = 'PR ';
SELECT * FROM country WHERE name = 'Portugal';
SELECT * FROM country WHERE name = 'Portugal ';


-- * numeric datatypes, CLOB (text)
CREATE TABLE movie (
    id varchar(10) PRIMARY KEY,
    official_title varchar(200) NOT NULL UNIQUE,
    budget numeric(12,2),
    year char(4) NOT NULL,
    length integer NOT NULL DEFAULT 0,
    plot text
);

INSERT INTO movie(id, official_title, year, length) VALUES ('0088763', 'Back to the Future', '1985', 116);
INSERT INTO movie(id, official_title, year, length) VALUES ('0084516', 'Poltergeist', '1982', 114);
INSERT INTO movie(id, official_title, year, length) VALUES ('0083866', 'E.T. the Extra-Terrestrial', '1982', 115);
INSERT INTO movie(id, official_title, year, length) VALUES ('0097576', 'Indiana Jones and the Last Crusade', '1989', 127);


-- * vincoli di chiave esterna
-- l'opzione ON DELETE CASCADE è preferibile, ma vediamo esempi con varie politiche (NO ACTION e CASCADE)
CREATE TABLE genre (
    movie varchar(10) NOT NULL REFERENCES movie(id) ON UPDATE CASCADE ON DELETE NO ACTION,
    genre varchar(20) NOT NULL,
    PRIMARY KEY(movie, genre)
);

INSERT INTO genre(movie, genre) VALUES ('0097576', 'Adventure');
INSERT INTO genre(movie, genre) VALUES ('0097576', 'Fantasy'); -- il riferimento al medesimo movie non è un problema
INSERT INTO genre(movie, genre) VALUES ('0083866', 'Family');
INSERT INTO genre(movie, genre) VALUES ('0088763', 'Adventure');
UPDATE genre SET movie = 'ABABAB' WHERE movie = '0097576'; -- errore: movie non esistente, vincolo di FK violato
UPDATE movie SET id = 'ABABAB' WHERE id = '0097576'; -- ok per effetto della politica CASCADE
DELETE FROM movie WHERE id = '0084516'; -- ok, nessuna tupla con questo valore di FK in genre
DELETE FROM movie WHERE id = '0088763'; -- errore per effetto di NO ACTION, provare con CASCADE (vedere comando ALTER sottostante

ALTER TABLE genre DROP CONSTRAINT genre_movie_id_fk;
ALTER TABLE genre ADD CONSTRAINT genre_movie_id_fk FOREIGN KEY (movie) REFERENCES movie(id) ON UPDATE CASCADE ON DELETE CASCADE;

-- * inclusione di cause nella chiave primaria
CREATE TABLE sim (
    movie1 varchar(10) NOT NULL REFERENCES movie(id) ON UPDATE CASCADE ON DELETE CASCADE,
    movie2 varchar(10) NOT NULL REFERENCES movie(id) ON UPDATE CASCADE ON DELETE CASCADE,
    cause varchar(10) NOT NULL,
    PRIMARY KEY (movie1, movie2, cause)
);

--* aggiunto attributo a tabella sim con valore compreso nell'intervallo (0, 1]
ALTER TABLE sim ADD COLUMN score numeric(3,2);
ALTER TABLE sim ADD CONSTRAINT score_check CHECK (score > 0 AND score <= 1);

-- * esempio con chiave esterna composta (non previsto dallo schema originario di IMDB)
CREATE TABLE theater (
	name varchar(50) NOT NULL,
	city varchar(50) NOT NULL,
	n_seats integer,
	PRIMARY KEY(name, city)
);

INSERT INTO theater VALUES ('Odeon', 'Milan');
INSERT INTO theater VALUES ('Plinius', 'Milan');
INSERT INTO theater VALUES ('Palestrina', 'Milan');

ALTER TABLE movie ADD COLUMN theater_preview varchar(50);
ALTER TABLE movie ADD COLUMN city_preview varchar(50);
ALTER TABLE movie ADD CONSTRAINT movie_theater_name_city_fk FOREIGN KEY (theater_preview, city_preview) REFERENCES theater(name, city) ON UPDATE CASCADE ON DELETE SET NULL;

UPDATE movie SET city_preview = 'Turin' WHERE id = '0097576' -- ok, not a FK
UPDATE movie SET theater_preview = 'Odeon' WHERE id = '0097576' -- errore, violazione del vincolo di FK
UPDATE movie SET city_preview = 'Milan', theater_preview = 'odeon'  WHERE id = '0097576' -- errore, PostgreSQL è case-sensitive sui valori degli attributi, vincolo FK violato
UPDATE movie SET city_preview = 'Milan', theater_preview = 'Odeon'  WHERE id = '0097576' -- ok, vincolo di FK valido
UPDATE theater SET name = 'Odeon Multisala' WHERE name = 'Odeon' AND city = 'Milan'; -- ok per effetto di CASCADE
DELETE FROM theater WHERE name = 'Odeon Multisala' AND city = 'Milan'; -- ok per effetto di SET NULL

-- * altri esempi con ALTER
CREATE TABLE rating (
    check_date date NOT NULL,
    source varchar(200) NOT NULL,
    movie varchar(10) NOT NULL REFERENCES movie(id) ON UPDATE CASCADE ON DELETE CASCADE,
    scale numeric NOT NULL,
    votes integer NOT NULL,
    score numeric NOT NULL,
    PRIMARY KEY(check_date, source, movie)
);

ALTER TABLE rating ALTER COLUMN check_date SET DEFAULT CURRENT_DATE;

INSERT INTO rating(check_date, source, movie, scale, votes, score) VALUES ('2017-11-05', 'IMDB', '0097576', 10, 569711, 8.3);
INSERT INTO rating(source, movie, scale, votes, score) VALUES ('IMDB', '0097576', 10, 494412, 7.4);

-- * visualizzazione degli attributi di tipo date e uso di funzioni built-in di PostgreSQL
SELECT check_date FROM rating WHERE movie = '0097576';
SELECT to_char(check_date, 'Day DD/MM/YY') AS "data del rating" FROM rating WHERE movie = '0097576';

-- *
-- Esempio di dominio definito dall'utente
CREATE DOMAIN sim_causes AS VARCHAR(11) CHECK (VALUE IN ('genre', 'plot', 'setting', 'hist period'));

ALTER TABLE sim ALTER COLUMN cause TYPE sim_causes;

-- esempio con check e alter
ALTER TABLE rating ADD CONSTRAINT check_score CHECK (score BETWEEN 0 AND scale);
INSERT INTO rating(check_date, source, movie, scale, votes, score) VALUES ('2017-11-05', 'IMDB', '0083866', 10, 307535, 11.2); -- errore, vincolo violato