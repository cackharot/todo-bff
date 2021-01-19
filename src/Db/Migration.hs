
module Db.Migration
where

import           Database.PostgreSQL.Simple
import           Db.Types
import           RIO

initDB :: PgSettings -> IO ()
initDB pgSettings = let connStr = connectionString pgSettings in 
  bracket (connectPostgreSQL connStr) close $ \conn -> do
    _ <- execute_ conn "CREATE TABLE IF NOT EXISTS todo (id int PRIMARY KEY not null, title text not null, description text null)"
    return ()
