CREATE TABLE storch_migrations (id integer, applied integer);

CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT UNIQUE,
  created_at TEXT NOT NULL,
  password TEXT NOT NULL
);

CREATE TABLE sqlite_sequence(name,seq);

CREATE INDEX index_users_on_email ON users(email);

CREATE TABLE groups (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  owner_id INTEGER,
  name TEXT NOT NULL,
  created_at TEXT NOT NULL,
  deleted_at TEXT,
  FOREIGN KEY (owner_id) REFERENCES users (id) ON DELETE SET NULL
);

CREATE INDEX index_groups_on_owner_id ON groups(owner_id);

CREATE TABLE group_memberships (
  user_id INTEGER,
  group_id INTEGER,
  PRIMARY KEY (user_id, group_id),
  FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
  FOREIGN KEY (group_id) REFERENCES groups (id) ON DELETE CASCADE
);

CREATE INDEX index_group_memberships_on_user_id ON group_memberships(user_id);

CREATE INDEX index_group_memberships_on_group_id ON group_memberships(group_id);

