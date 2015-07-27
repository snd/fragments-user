-- case insensitive text datatype
CREATE EXTENSION IF NOT EXISTS "citext";

CREATE TABLE "user"(
  -- in practice user ids must often be handled by humans.
  -- integer ids for users are much easier to handle than uuids.
  -- it is impossible that we exhaust the numbers fitting
  -- into bigint on the users table
  -- 8 bytes
  id BIGSERIAL PRIMARY KEY,

  email citext UNIQUE NOT NULL CHECK (email <> ''),

  name text UNIQUE NOT NULL CHECK (name <> ''),

  password text NOT NULL CHECK (password <> ''),

  created_at timestamptz NOT NULL,

  rights text NOT NULL
);
