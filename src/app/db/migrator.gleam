import app/db/connection
import feather
import feather/migrate as migrator

pub fn migrate_to_latest() {
  let assert Ok(migrations) = migrator.get_migrations("src/app/db/migrations")

  let assert Ok(connection) =
    feather.connect(
      feather.Config(..feather.default_config(), file: connection.get_db_path()),
    )

  migrator.migrate(migrations, connection)
}
