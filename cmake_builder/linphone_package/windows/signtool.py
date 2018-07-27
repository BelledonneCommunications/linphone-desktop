#!/usr/bin/env python
import os, sys
import subprocess
class PassFile:
       def __init__(self, file):
               self.file = file
       def password(self, v):
               file = open(self.file, "r");
               line = file.readline().strip()
               file.close()
               return line
 
if __name__ == '__main__':
  if len(sys.argv) <= 2:
    sys.exit(0)
  for i,arg in enumerate(sys.argv):
    if arg == "/p":
      if (i + 1) == len(sys.argv):
        print "Missing password argument"
        sys.exit(3)
      try:
        sys.argv[i+1] = PassFile(sys.argv[i+1]).password(None)
      except IOError:
        print "Password file not found"
        sys.exit(3)
  actual_args = sys.argv[1:]
  ret = subprocess.call(actual_args)
  sys.exit(ret)
