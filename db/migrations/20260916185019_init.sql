-- +goose Up
CREATE TABLE users (
  id   BIGSERIAL PRIMARY KEY,
  email text UNIQUE NOT NULL
);

-- +goose Down
DROP TABLE IF EXISTS users; 