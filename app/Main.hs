{-# LANGUAGE TemplateHaskell   #-}
module Main where

import RIO
import Chakra (appVersion, withAppSettingsFromEnv)
import qualified Data.Text as T
import Todo
import Configuration.Dotenv (defaultConfig, loadFile, Config(..))
import Options.Applicative.Simple
import qualified Paths_todo_bff

main :: IO ()
main = do
    hSetBuffering stdin LineBuffering
    _ <- loadFile defaultConfig {configPath = [".env", ".env.secrets"]} -- load .env & .env.secrets file if available
    withAppSettingsFromEnv $ \appSettings -> do
      withAppSettingsFromEnv $ \pgSettings -> do
        -- Override the version from cabal file
        let ver = $(simpleVersion Paths_todo_bff.version) -- TH to get cabal project's git sha version
            infoDetail = appSettings {appVersion = T.pack ver}
        startApp infoDetail pgSettings
