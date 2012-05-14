import contextlib
import os

@contextlib.contextmanager
def cwd(path):
  saved = os.getcwd()
  try:
    os.chdir(path)
    yield
  finally:
    os.chdir(saved)
