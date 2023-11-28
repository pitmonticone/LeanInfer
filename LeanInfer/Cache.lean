import Lean
import LeanInfer.Config

open Lean System

namespace LeanInfer.Cache


private def getHomeDir : IO FilePath := do
  let some dir ← IO.getEnv "HOME" | throw $ IO.userError "Cannot find the $HOME environment variable."
  return dir


private def ensureDirExists (dir : FilePath) : IO Unit := do
  if !(← dir.pathExists)  then
    IO.FS.createDirAll dir


def getDefaultCacheDir : IO FilePath := do
  return (← getHomeDir) / ".cache" / "lean_infer"


def getCacheDir : IO FilePath := do
  let defaultCacheDir ← getDefaultCacheDir
  let dir := match ← IO.getEnv "LEAN_INFER_CACHE_DIR" with
  | some dir => (dir : FilePath)
  | none => defaultCacheDir
  ensureDirExists dir
  return dir.normalize


private def getModelDir (url : HuggingFaceURL) : IO FilePath := do
  let cacheDir ← getCacheDir
  let dir := match url.user with
  | none => cacheDir / url.modelName
  | some user => cacheDir / user / url.modelName
  return dir.normalize


/--
Return the cache directory for storing the current model.
-/
def getGeneratorDir : IO FilePath := do
  getModelDir (← getGeneratorUrl)


def getEncoderDir : IO FilePath := do
  getModelDir (← getEncoderUrl)


end LeanInfer.Cache
