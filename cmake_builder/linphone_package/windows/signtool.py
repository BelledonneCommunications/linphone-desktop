#!/usr/bin/env python
#
# Copyright (c) 2010-2020 Belledonne Communications SARL.
#
# This file is part of linphone-desktop
# (see https://www.linphone.org).
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
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
