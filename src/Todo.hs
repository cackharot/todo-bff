{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE TypeOperators     #-}
module Todo
    ( startApp
    ) where

import RIO
import Chakra
import Servant
import Data.Aeson.TH

data Todo = Todo
  { _id        :: Int
  , _title :: String
  , _description  :: String
  } deriving (Eq, Show)

$(deriveJSON defaultOptions ''Todo)

type TodoRoute = "todo" :> Get '[JSON] [Todo]

type API = TodoRoute :<|> EmptyAPI

todoServer :: BasicApp [Todo]
todoServer = getTodo

getTodo :: BasicApp [Todo]
getTodo = return $ [ Todo 1 "Add Conn pool" "desc"
        , Todo 2 "Store in PostgreSQL" "desc"
        ]

startApp :: InfoDetail -> IO ()
startApp infoDetail = do
  let appEnv = appEnvironment infoDetail
      appVer = appVersion infoDetail
      appAPI = Proxy :: Proxy API
      appServer = todoServer :<|> emptyServer
  logFunc <- buildLogger appEnv appVer
  middlewares <- chakraMiddlewares infoDetail
  runChakraAppWithMetrics
    middlewares
    EmptyContext
    (logFunc, infoDetail)
    appAPI
    appServer
