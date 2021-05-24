{-# LANGUAGE TypeApplications #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Main where

import Control.Lens.Operators ((.~))
import Control.Monad.Logger (MonadLogger)
import Data.Default (Default (def))
import Data.LVar (LVar)
import qualified Ema
import qualified Ema.Helper.FileSystem as FileSystem
import qualified Ema.Helper.Tailwind as Tailwind
import Emanote.Class ()
import Emanote.Model (Model)
import qualified Emanote.Model as M
import qualified Emanote.Source as Source
import qualified Emanote.Source.Default as SourceDefault
import qualified Emanote.Template as Template
import Main.Utf8 (withUtf8)
import UnliftIO (MonadUnliftIO)

main :: IO ()
main =
  withUtf8 $
    Ema.runEma (Template.render . cssShim) run
  where
    cssShim =
      Tailwind.twindShim

run :: (MonadUnliftIO m, MonadLogger m) => LVar Model -> m ()
run modelLvar = do
  -- TODO: Monitor the default files; only if running in ghcid.
  -- Otherwise configure ghcid to reload when this directory is changed.
  defaultTmpl <- SourceDefault.emanoteDefaultTemplates
  defaultData <- SourceDefault.emanoteDefaultIndexData
  let model0 =
        def
          & M.modelHeistTemplate .~ defaultTmpl
          & M.modelDataDefault .~ defaultData
  FileSystem.mountOnLVar
    "."
    Source.filePatterns
    Source.ignorePatterns
    modelLvar
    model0
    Source.transformActions
