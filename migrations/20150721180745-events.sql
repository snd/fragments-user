CREATE TYPE my_event_type AS ENUM (
  -- contains whether from invite and from waitlist
  'signup',
  'waitlist',
  'login',
  'delete'
);

CREATE TABLE event (
  id BIGSERIAL PRIMARY KEY,
  created_at timestamptz NOT NULL,
  user_id citext NULL,
  type my_event_type NOT NULL,
  data JSONB NOT NULL
);
