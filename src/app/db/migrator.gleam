import app/db/connection
import app/lib/logger
import feather
import feather/migrate as migrator
import wisp

pub fn migrate_to_latest() {
  logger.info("Fetching migrations...")

  let assert Ok(priv_dir) = wisp.priv_directory("okane")

  let assert Ok(migrations) = migrator.get_migrations(priv_dir <> "/migrations")

  logger.info("Acquiring connection...")

  let assert Ok(connection) =
    feather.connect(
      feather.Config(..feather.default_config(), file: connection.get_db_path()),
    )

  logger.info("Running migrations...")

  migrator.migrate(migrations, connection)
}
