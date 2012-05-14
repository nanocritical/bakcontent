import os
import os.path
import shutil
import errno
import subprocess

class Disk(object):
  def __init__(self, contentdir):
    self.contentdir = contentdir
    self._prepare_dir()

  def _prepare_dir(self):
    if not os.path.isdir(self.contentdir):
      print "Initializing content directory '%s'..." % self.contentdir
      os.makedirs(self.contentdir)
      for prefix in range(256):
        os.makedirs(os.path.join(self.contentdir, "%02x" % prefix))

  def save_content(self, h, tmp_cfn):
    prefix = h[0:2]
    shutil.move(tmp_cfn, os.path.join(self.contentdir, prefix, h))
