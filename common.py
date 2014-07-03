import contextlib
import os
import sys
import errno
import tempfile
import shutil
import socket
import hashlib

# Why the merry fuck os.path.join? "If any component is an absolute path,
# all previous path components will be discarded."
#
# "I don't know, why don't you try rmtree(os.path.join('blah', 'doh', '/home/user')). Oups."
#
# You're fucking banned.
insane_join = os.path.join
os.path.join = None
def sane_join(*args):
    return insane_join(args[0], *[a.lstrip('/') for a in args[1:]])
os.path.join = sane_join
assert os.path.join('/absolute', '/absolute2/b/c/d') == '/absolute/absolute2/b/c/d'
assert os.path.join('relative', '/absolute', '/absolute2/b/c/d') == 'relative/absolute/absolute2/b/c/d'

def args_default(argparser):
    argparser.add_argument('--bakcontent', default='.bakcontent',
            help=("path to .bakcontent of repo (for instance /home/e/.bakcontent);"
                + " defaults to '.bakcontent', or 'ROOT/.bakcontent' if --root is used"))

def args_parse_dirs(args):
    bakdir = args.bakcontent
    if not os.path.basename(bakdir) == '.bakcontent':
        eprint("Error: '%s' is a malformed .bakcontent directory name" % bakdir)
        exit(1)
    if not os.path.isdir(bakdir):
        eprint("Error: '%s' not a valid .bakcontent directory (missing)" % bakdir)
        exit(1)
    elif not os.path.exists(os.path.join(bakdir, 'root')):
        eprint("Error: '%s' not a valid .bakcontent directory (file 'root' missing)" % bakdir)
        exit(1)
    return os.path.realpath(bakdir)

def get_rootdir(bakdir):
    with pushdir(bakdir):
        with open('root') as f:
            rootdir = os.path.realpath(f.read().strip())
    return rootdir

def eprint(*args):
    print>>sys.stderr, ' '.join(args)

def trymakedirs(dn):
    if dn == '':
        return
    try:
        os.makedirs(dn)
    except OSError, e:
        if e.errno == errno.EEXIST:
            if not os.path.isdir(dn):
                raise e
        else:
            raise e

@contextlib.contextmanager
def pushdir(path, create=False):
    saved = os.getcwd()
    try:
        if create and not os.path.isdir(path):
            trymakedirs(path)
        os.chdir(path)
        yield
    finally:
        os.chdir(saved)

@contextlib.contextmanager
def atomicopenw(fn):
    f = None
    try:
        (tmpfd, tmpfn) = tempfile.mkstemp(prefix='bakcontenttmp', dir=os.path.dirname(fn))
        f = os.fdopen(tmpfd, 'w')
        yield f
    finally:
        if f is not None:
            f.close()
            os.rename(tmpfn, fn)

def shell(*args):
    status = os.system(' '.join(args))
    if os.WIFSIGNALED(status):
        return 1
    elif os.WIFEXITED(status):
        return os.WEXITSTATUS(status)
    else:
        return 1

def hist_store_path(bakdir):
    return os.path.join('histories', socket.gethostname(), os.path.abspath(bakdir))

def data_path(store_spec, sha512):
    prefix = sha512[0:3]
    return os.path.join(store_spec, 'data', prefix, sha512)

class Store(object):
    LOCAL, SSH, S3 = range(3)

    def __init__(self, bakdir, name, spec=None):
        self.bakdir = bakdir
        self.histdir = os.path.join(bakdir, 'history')
        self.name = name
        if spec is not None:
            self.spec = spec
        else:
            with pushdir(os.path.join(self.bakdir, 'stores'), create=True):
                with open(self.name) as f:
                    self.spec = f.read().strip()
        if self.spec.startswith('s3://'):
            self.kind = Store.S3
        elif self.spec.startswith('ssh://'):
            self.kind = Store.SSH
        else:
            self.kind = Store.LOCAL

    def add(self):
        if self.kind == Store.LOCAL:
            self.spec = os.path.abspath(self.spec)
            trymakedirs(self.spec)
            if not os.path.isdir(self.spec):
                eprint("Error: local store directory '%s' does not exist (and cannot create it), or is not a directory" % self.spec)
                exit(1)
            with atomicopenw(os.path.join(self.spec, '.nobakcontent')) as f:
                # Touch.
                pass

        with pushdir(os.path.join(self.bakdir, 'stores'), create=True):
            if os.path.exists(self.name):
                eprint("Error: store '%s' already exists" % self.name)
                exit(1)
            with atomicopenw(self.name) as f:
                f.write(self.spec)

    def rm(self):
        with pushdir(self.bakdir):
            os.unlink(os.path.join('stores', self.name))

    def archive(self, fn, maybe_sha512):
        if self.kind == Store.LOCAL:
            self.archive_local(fn, maybe_sha512)
        elif self.kind == Store.SSH:
            self.archive_ssh(fn, maybe_sha512)
        elif self.kind == Store.S3:
            self.archive_s3(fn, maybe_sha512)

    def archive_local(self, fn, maybe_sha512):
        # (Optimistically) Check for existence with 'maybe_sha512' (if not
        # None), but always store under real, computed-during-copy SHA-512 to
        # work in the presence of races with concurrent writers to 'fn'.
        if maybe_sha512 is not None:
            dstfn = data_path(self.spec, maybe_sha512)
            if os.path.exists(dstfn):
                return

        (tmpfd, tmpfn) = tempfile.mkstemp(prefix='bakcontentpartial', dir=self.spec)
        out = os.fdopen(tmpfd, 'w')
        try:
            try:
                h = hashlib.sha512()

                if os.path.islink(fn):
                    buf = os.readlink(fn)
                    h.update(buf)
                    out.write(buf)
                    sha512 = h.hexdigest()

                else:
                    with open(fn) as f:
                        while True:
                            buf = f.read(256*1024)
                            h.update(buf)
                            out.write(buf)
                            if len(buf) < 256*1024:
                                break
                        sha512 = h.hexdigest()
            finally:
                out.close()

            dstfn = data_path(self.spec, sha512)
            if not os.path.exists(dstfn):
                trymakedirs(os.path.dirname(dstfn))
                os.rename(tmpfn, dstfn)
            else:
                os.unlink(tmpfn)
        except Exception, e:
            os.unlink(tmpfn)
            raise e

    def archive_ssh(self, fn, maybe_sha512):
        assert False

    def archive_s3(self, fn, maybe_sha512):
        assert False

    def archive_history(self):
        if self.kind == Store.LOCAL:
            self.archive_history_local()
        elif self.kind == Store.SSH:
            self.archive_history_ssh()
        elif self.kind == Store.S3:
            self.archive_history_ssh()

    def archive_history_local(self):
        dsthistdir = os.path.join(self.spec, hist_store_path(self.bakdir))
        trymakedirs(dsthistdir)
        with pushdir(dsthistdir):
            ignore = shell('git init --bare > /dev/null')
            e = shell("git remote add origin '%s' 2> /dev/null" % self.histdir)
            if e:
                ignore = shell("git remote remove origin")
                e = shell("git remote add origin '%s'" % self.histdir)
                if e:
                    eprint("Error in git remote add")
                    exit(e)
            e = shell("git fetch -t origin 2> /dev/null")
            if e:
                eprint("Error in git fetch")
                exit(e)
            e = shell("git gc &> /dev/null")
            if e:
                eprint("Error in git gc")
                exit(e)

    def archive_history_ssh(self):
        assert False

    def archive_history_s3(self):
        assert False
