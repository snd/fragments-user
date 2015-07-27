-- invite requests
CREATE TABLE waitlist(
  id BIGSERIAL PRIMARY KEY,
  email citext UNIQUE NOT NULL CHECK (email <> ''),
  created_at timestamptz NOT NULL
);

CREATE TABLE invite(
  id BIGSERIAL PRIMARY KEY,
  waitlist_id BIGINT NULL REFERENCES waitlist(id),

  created_at timestamptz NOT NULL
);
