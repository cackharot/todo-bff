{-# LANGUAGE DataKinds       #-}
{-# LANGUAGE DeriveAnyClass  #-}
{-# LANGUAGE DeriveGeneric   #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeOperators   #-}

module Todo
  ( startApp,
  )
where

import           Chakra
import           Data.Aeson.TH
import           Data.Pool
import           Database.PostgreSQL.Simple
import           Database.PostgreSQL.Simple.FromRow
import           Db.Connection
import           Db.Migration
import           RIO
import           Servant
-- import Prelude (print)
import           Types

data Todo = Todo
  { _id          :: Int,
    _title       :: String,
    _description :: String
  }
  deriving (Eq, Show)

$(deriveJSON defaultOptions ''Todo)

instance FromRow Todo where
  fromRow = Todo <$> field <*> field <*> field

type TodoRoute = "todo" :> Get '[JSON] [Todo]

type API = TodoRoute :<|> EmptyAPI

type TodoAppCtx = (ModLogger, InfoDetail, DbConnection)

type TodoApp = RIO TodoAppCtx

todoServer :: TodoApp [Todo]
todoServer = getTodo

getTodo :: TodoApp [Todo]
getTodo = do
  conns <- askObj
  liftIO $
    withResource conns $ \conn ->
      query_ conn "SELECT id,title,description FROM todo WHERE 1=1"


startApp :: InfoDetail -> PgSettings -> IO ()
startApp infoDetail pgSettings = do
  pool <- initConnectionPool pgSettings
  initDB pgSettings
  -- withResource pool $ \conn ->  mapM_ print =<<
  --   (query_
  --      conn
  --      "SELECT id,title,description FROM todo WHERE 1=1" :: IO [Todo])
  let appEnv = appEnvironment infoDetail
      appVer = appVersion infoDetail
      appAPI = Proxy :: Proxy API
      appServer = todoServer :<|> emptyServer
  logFunc <- buildLogger appEnv appVer
  middlewares <- chakraMiddlewares infoDetail
  runChakraAppWithMetrics
    middlewares
    EmptyContext
    (logFunc, infoDetail, pool)
    appAPI
    appServer
