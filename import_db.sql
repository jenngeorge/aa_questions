DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT,
  lname TEXT
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT,
  body TEXT,
  user_id INTEGER,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  question_id INTEGER,
  user_id INTEGER,
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body TEXT,
  question_id INTEGER,
  user_id INTEGER,
  parent_id INTEGER,
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id)

);

DROP TABLE IF EXISTS questions_likes;

CREATE TABLE questions_likes (
  id INTEGER PRIMARY KEY,
  question_id INTEGER,
  user_id INTEGER,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)

);

INSERT INTO
  users(fname, lname)

VALUES
('Jenn', 'George'),
('Joel', 'Mangin');

INSERT INTO
questions(title, body, user_id)
VALUES
("how does SQL work?", "Like Magic", (SELECT id FROM users WHERE fname = 'Joel'));

INSERT INTO
replies(body, question_id, user_id, parent_id)
VALUES
  ('ok', (SELECT id FROM questions WHERE title= 'how does SQL work?'), (SELECT user_id FROM questions WHERE title='how does SQL work?'), (SELECT id FROM questions WHERE title= 'how does SQL work?'));
