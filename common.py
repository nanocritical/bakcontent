import contextlib
import os
import sys
import errno
import tempfile
import shutil

def args_default(argparser):
    argparser.add_argument('--bakcontent', default='.bakcontent',
            help=("path to .bakcontent of repo (for instance /home/e/.bakcontent);"
                + " defaults to '.bakcontent', or 'ROOT/.bakcontent' if --root is used"))

def args_parse_dirs(args):
    bakdir = args.bakcontent
    if not os.path.isdir(bakdir):
        eprint("'%s' not a valid .bakcontent directory" % bakdir)
        exit(1)
    return bakdir

def get_rootdir(bakdir):
    with pushdir(bakdir):
        with open('root') as f:
            rootdir = os.path.realpath(f.read().strip())
    return rootdir

def eprint(*args):
    print>>sys.stderr, ' '.join(args)

def trymakedirs(dn):
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

class Store(object):
    LOCAL, SSH, S3 = range(3)

    def __init__(self, bakdir, name, spec=None):
        self.bakdir = bakdir
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
            os.remove(os.path.join('stores', self.name))

    def archive(self, sha512, fn):
        if self.kind == Store.LOCAL:
            self.archive_local(sha512, fn)
        elif self.kind == Store.SSH:
            self.archive_ssh(sha512, fn)
        elif self.kind == Store.S3:
            self.archive_ssh(sha512, fn)

    def archive_local(self, sha512, fn):
        prefix = sha512[0:2]
        dstfn = os.path.join(self.spec, prefix, sha512)
        if not os.path.exists(dstfn):
            trymakedirs(os.path.dirname(dstfn))
            shutil.copy(fn, dstfn)

    def archive_ssh(self, sha512, fn):
        assert False

    def archive_s3(self, sha512, fn):
        assert False
