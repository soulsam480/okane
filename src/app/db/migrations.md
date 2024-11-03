## Migrations cheat sheet
```sql
-- Original migration tracking
CREATE TABLE migrations (
   id INTEGER PRIMARY KEY,
   name TEXT,
   applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Basic table operations
CREATE TABLE users (
   id INTEGER PRIMARY KEY,
   name TEXT
);

ALTER TABLE users ADD COLUMN email TEXT;
ALTER TABLE users RENAME TO old_users;
DROP TABLE users;

-- Indexes
CREATE INDEX idx_user_email ON users(email);
DROP INDEX idx_user_email;

-- Foreign Keys with ON DELETE/UPDATE actions
CREATE TABLE posts (
   id INTEGER PRIMARY KEY,
   user_id INTEGER,
   FOREIGN KEY(user_id) REFERENCES users(id)
       ON DELETE CASCADE    -- Delete posts when user deleted
       ON UPDATE CASCADE    -- Update if user_id changes
);

CREATE TABLE comments (
   id INTEGER PRIMARY KEY,
   post_id INTEGER,
   FOREIGN KEY(post_id) REFERENCES posts(id)
       ON DELETE SET NULL   -- Set post_id to NULL when post deleted
);

CREATE TABLE logs (
   id INTEGER PRIMARY KEY,
   user_id INTEGER,
   FOREIGN KEY(user_id) REFERENCES users(id)
       ON DELETE RESTRICT   -- Prevent user deletion if logs exist
);

-- Triggers
CREATE TRIGGER update_user_timestamp
AFTER UPDATE ON users
BEGIN
   UPDATE users SET updated_at = DATETIME('now')
   WHERE id = NEW.id;
END;

-- Views
CREATE VIEW active_users AS
SELECT * FROM users 
WHERE last_login > date('now', '-30 days');

-- Rolling back
BEGIN TRANSACTION;
-- your changes
ROLLBACK; -- or COMMIT;

-- Common column constraints
NOT NULL
UNIQUE 
DEFAULT value
CHECK (condition)
PRIMARY KEY
AUTOINCREMENT

-- Data types
INTEGER
TEXT
REAL
BLOB
NULL
DATETIME
BOOLEAN

-- Useful date functions
DATE('now')
DATETIME('now')
DATE('now', '+1 day')
DATE('now', '-1 month')
STRFTIME('%Y-%m-%d', 'now')

-- Version tracking example
INSERT INTO migrations (name) VALUES ('create_users_20240101');

-- Common Queries with constraints
PRAGMA foreign_keys = ON;  -- Enable foreign key support
PRAGMA journal_mode = WAL; -- Write-Ahead Logging mode
```
