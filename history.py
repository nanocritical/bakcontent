import os
import os.path
import subprocess
import contextlib

@contextlib.contextmanager
def wd(path):
  saved = os.getcwd()
  try:
    os.chdir(path)
    yield
  finally:
    os.chdir(saved)

class History(object):
  def __init__(self, metadir):
    self.metadir = metadir
    self._prepare_dir()

  def _git(self, *args):
    assert len(args) > 0
    with wd(self.metadir):
      subprocess.check_call(['git'] + list(args))

  def _prepare_dir(self):
    if not os.path.isdir(self.metadir):
      os.makedirs(self.metadir)
    if not os.path.lexists(os.path.join(self.metadir, '.git')):
      self._git('init')
    if not os.path.isdir(os.path.join(self.metadir, '.git')):
      raise Exception("History repository exists but is not a valid git repository: '%s'" \
          % self.metadir)

  def add_meta(self, mfn):
    self._git('add', mfn)

  def commit(self):
    self._git('commit', '-a', '-F', '/dev/null', '--allow-empty-message')
