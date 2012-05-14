import struct
import math
import sys
import os

def file_entropy_estimate(basedir, fn):
  '''Entropy of the first 4096 bytes of the file.'''
  with open(os.path.join(basedir, fn)) as f:
    begin = f.read(4096)
  len_begin = len(begin)
  byte_frequency = [0 for _ in xrange(256)]
  for i in xrange(len_begin):
    b = struct.unpack_from('B', begin, i)[0]
    byte_frequency[b] += 1

  entropy = 0
  for count in byte_frequency:
    if count == 0:
      continue
    f = float(count) / len_begin
    entropy -= f * math.log(f, 256)

  return entropy

def is_worth_deflating(basedir, fn):
  '''
  - English text or source code appears to be around .6
  - Fully compressed content is > .95 (jpg, png, zip, ...)
  - PDFs with compressed content can be as low as .90 (as PDF commands
    themselves are not all compressed.
  - Very small compressed files are about .75, we choose a threshold under
    that.
  '''
  return file_entropy_estimate(basedir, fn) < .7

if __name__ == '__main__':
  print file_entropy_estimate('', sys.argv[1])
