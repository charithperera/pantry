-- CREATE DATABASE pantry;
--
-- DROP TABLE users;
-- DROP TABLE foods;
-- DROP TABLE entries;
-- DROP TABLE daily_stats;
--
-- CREATE TABLE users (
--   id SERIAL4 PRIMARY KEY,
--   email VARCHAR(200) NOT NULL,
--   password_digest VARCHAR(100) NOT NULL
-- );
--
-- CREATE TABLE foods (
--   id SERIAL4 PRIMARY KEY,
--   brand VARCHAR(50),
--   name VARCHAR(100),
--   calories REAL,
--   fat REAL,
--   carbs REAL,
--   protein REAL
-- );
--
-- CREATE TABLE entries (
--   id SERIAL4 PRIMARY KEY,
--   user_id INTEGER,
--   food_id INTEGER,
--   entry_date DATE
-- );
--
-- CREATE TABLE daily_stats (
--   id SERIAL4 PRIMARY KEY,
--   user_id INTEGER,
--   stat_date DATE,
--   calories REAL DEFAULT 0.0,
--   fat REAL DEFAULT 0.0,
--   carbs REAL DEFAULT 0.0,
--   protein REAL DEFAULT 0.0
-- );

CREATE DATABASE pantry;

DROP TABLE users;
DROP TABLE foods;
DROP TABLE entries;
DROP TABLE daily_stats;

CREATE TABLE users (
  id SERIAL4 PRIMARY KEY,
  email VARCHAR(200) NOT NULL,
  password_digest VARCHAR(100) NOT NULL
);

CREATE TABLE foods (
  id SERIAL4 PRIMARY KEY,
  brand VARCHAR(50),
  name VARCHAR(100),
  calories REAL,
  fat REAL,
  carbs REAL,
  protein REAL
);

CREATE TABLE entries (
  id SERIAL4 PRIMARY KEY,
  user_id INTEGER,
  food_id INTEGER,
  entry_date DATE
);

CREATE TABLE daily_stats (
  id SERIAL4 PRIMARY KEY,
  user_id INTEGER,
  stat_date DATE,
  calories INTEGER DEFAULT 0,
  fat DECIMAL(2) DEFAULT 0.0,
  carbs DECIMAL(2) DEFAULT 0.0,
  protein DECIMAL(2) DEFAULT 0.0
);
