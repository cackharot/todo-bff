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
import           Network.HTTP.Types                 (status200)
import           Network.HTTP.Types.Header          (hContentType)
import           Network.Wai                        (responseLBS)
import           Network.Wai.Cli
import           Types
import           Network.Wai.Middleware.Health (health)

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

type API = TodoRoute :<|> "hello" :> Raw :<|> EmptyAPI

type TodoAppCtx = (ModLogger, InfoDetail, DbConnection)

type TodoApp = RIO TodoAppCtx

todoServer :: TodoApp [Todo]
todoServer = getTodo

basic :: ServerT Raw TodoApp
basic = pure hello

hello :: Application
hello _req f = f $ responseLBS status200 [(hContentType, "text/plain")] "Hello world!"

getTodo :: TodoApp [Todo]
getTodo = do
  conns <- askObj
  liftIO $
    withResource conns $ \conn ->
      query_ conn "SELECT id,title,description FROM todo WHERE 1=1"


-- startApp :: InfoDetail -> PgSettings -> IO ()
-- startApp infoDetail pgSettings  = do
--   liftIO $ defWaiMain hello

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
      appServer = todoServer :<|> basic :<|> emptyServer
  logFunc <- buildLogger appEnv appVer
  -- middlewares <- chakraMiddlewares infoDetail
  let middlewares = health
  runChakraAppWithMetrics
    middlewares
    EmptyContext
    (logFunc, infoDetail, pool)
    appAPI
    appServer
