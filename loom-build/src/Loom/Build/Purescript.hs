{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
module Loom.Build.Purescript (
    LoomPurescriptError (..)
  , generatePurescript
  ) where


import           Control.Monad.IO.Class (liftIO)

import qualified Data.Char as Char
import qualified Data.Text as T

import           Loom.Build.Data
import           Loom.Core.Data
import           Loom.Projector (ProjectorPurescriptError)
import qualified Loom.Projector as Projector

import           P

import           System.Directory (createDirectoryIfMissing)
import           System.FilePath ((</>), takeFileName)
import           System.IO (IO, FilePath)

import           X.Control.Monad.Trans.Either (EitherT)


data LoomPurescriptError =
     LoomPurescriptProjectorError ProjectorPurescriptError
  deriving (Show)

generatePurescript ::
     FilePath
  -> CssFile
  -> [ImageFile]
  -> [(BundleName, JsFile)]
  -> Projector.ProjectorOutput
  -> EitherT LoomPurescriptError IO ()
-- FIXME real type signature should be like so
-- LoomSitePrefix -> AssetsPrefix -> LoomResult -> EitherT LoomPurescriptError IO ()
generatePurescript output inputCss images inputJs po = do
  -- TODO MAchinator
  let
    --n = (T.map (\c -> if Char.isAlphaNum c then Char.toLower c else '-') . renderLoomName) name <> "loom"
    n = "loom"
    outputCss = CssFile $ output </> (takeFileName . renderCssFile) inputCss
    outputJs' = with inputJs . fmap $ \jsfile -> JsFile $ output </> takeFileName (renderJsFile jsfile)
    output' = output </> T.unpack n </> "src"
    spx = LoomSitePrefix "FIXME"
    apx = AssetsPrefix "FIXME"
  liftIO $
    createDirectoryIfMissing True output
  void . firstT LoomPurescriptProjectorError $
    Projector.generateProjectorPurescript output' spx apx [outputCss] images outputJs' po