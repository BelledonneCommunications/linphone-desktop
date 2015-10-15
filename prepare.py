#!/usr/bin/env python

############################################################################
# prepare.py
# Copyright (C) 2015  Belledonne Communications, Grenoble France
#
############################################################################
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#
############################################################################

import argparse
import os
import platform
import sys
from subprocess import Popen
from distutils.spawn import find_executable
sys.dont_write_bytecode = True
sys.path.insert(0, 'submodules/cmake-builder')
try:
    import prepare
except:
    print(
        "Could not find prepare module, probably missing submodules/cmake-builder? Try running:\ngit submodule update --init --recursive")
    exit(1)


class DesktopTarget(prepare.Target):

    def __init__(self):
        prepare.Target.__init__(self, '')
        current_path = os.path.dirname(os.path.realpath(__file__))
        if platform.system() == 'Windows':
            current_path = current_path.replace('\\', '/')
        self.config_file = 'configs/config-desktop.cmake'
        self.additional_args = [
            '-DLINPHONE_BUILDER_EXTERNAL_SOURCE_PATH=' +
            current_path + '/submodules'
        ]


def check_is_installed(binary, prog=None, warn=True):
    if not find_executable(binary):
        if warn:
            print("Could not find {}. Please install {}.".format(binary, prog))
        return False
    return True


def check_tools():
    ret = 0

    if " " in os.path.dirname(os.path.realpath(__file__)):
        print("Invalid location: path should not contain any spaces.")
        ret = 1

    print("check_tools: todo.. (see ios)")
    return ret

def generate_makefile(generator):
    makefile = """
.PHONY: all

build:
\t{generator} WORK/cmake

WORK/build.done:
\t{generator} WORK/cmake && touch WORK/build.done

dev: WORK/build.done
\t{generator} WORK/Build/linphone_builder install

all: build

pull-transifex:
\t$(MAKE) -C linphone pull-transifex

push-transifex:
\t$(MAKE) -C linphone push-transifex

help-prepare-options:
\t@echo "prepare.py was previously executed with the following options:"
\t@echo "   {options}"

help: help-prepare-options
\t@echo ""
\t@echo "(please read the README.md file first)"
\t@echo ""
\t@echo "Available targets:"
\t@echo ""
\t@echo "   * all, build  : normal build"
\t@echo "   * dev         : build only linphone related source code (used for development)"
\t@echo ""
""".format(options=' '.join(sys.argv), generator=generator)
    f = open('Makefile', 'w')
    f.write(makefile)
    f.close()


def main(argv=None):
    if argv is None:
        argv = sys.argv
    argparser = argparse.ArgumentParser(
        description="Prepare build of Linphone and its dependencies.")
    argparser.add_argument(
        '-ac', '--all-codecs', help="Enable all codecs, including the non-free ones", action='store_true')
    argparser.add_argument(
        '-c', '-C', '--clean', help="Clean a previous build instead of preparing a build.", action='store_true')
    argparser.add_argument(
        '-d', '--debug', help="Prepare a debug build, eg. add debug symbols and use no optimizations.", action='store_true')
    argparser.add_argument(
        '-dv', '--debug-verbose', help="Activate ms_debug logs.", action='store_true')
    argparser.add_argument(
        '-f', '--force', help="Force preparation, even if working directory already exist.", action='store_true')
    argparser.add_argument(
        '-G', '--generator', help="CMake build system generator (default: Unix Makefiles, use cmake -h to get the complete list).", default='Unix Makefiles', dest='generator')
    argparser.add_argument(
        '-L', '--list-cmake-variables', help="List non-advanced CMake cache variables.", action='store_true', dest='list_cmake_variables')
    argparser.add_argument(
        '-m', '--minimal', help="Build a minimal version of Linphone.", action='store_true')
    argparser.add_argument(
        '-os', '--only-submodules', help="Build only submodules (finding all dependencies on the system.", action='store_true')
    argparser.add_argument(
        '-t', '--tunnel', help="Enable Tunnel.", action='store_true')

    args, additional_args = argparser.parse_known_args()

    additional_args += ["-G", args.generator]
    additional_args += ["-DLINPHONE_BUILDER_GROUP_EXTERNAL_SOURCE_PATH_BUILDERS=YES"]

    if args.debug_verbose:
        additional_args += ["-DENABLE_DEBUG_LOGS=YES"]

    if args.only_submodules:
        additional_args += ["-DLINPHONE_BUILDER_BUILD_ONLY_EXTERNAL_SOURCE_PATH=YES"]

    if args.minimal:
        additional_args += ["-DENABLE_VIDEO=NO",
                            "-DENABLE_MKV=NO",
                            "-DENABLE_AMRNB=NO",
                            "-DENABLE_AMRWB=NO",
                            "-DENABLE_G729=NO",
                            "-DENABLE_GSM=NO",
                            "-DENABLE_ILBC=NO",
                            "-DENABLE_ISAC=NO",
                            "-DENABLE_OPUS=NO",
                            "-DENABLE_SILK=NO",
                            "-DENABLE_SPEEX=NO",
                            "-DENABLE_SRTP=NO",
                            "-DENABLE_ZRTP=NO",
                            "-DENABLE_WASAPI=NO",
                            "-DENABLE_PACKAGING=NO"]

    if args.all_codecs:
        additional_args += ["-DENABLE_NON_FREE_CODECS=YES",
                            "-DENABLE_AMRNB=YES",
                            "-DENABLE_AMRWB=YES",
                            "-DENABLE_G729=YES",
                            "-DENABLE_H263=YES",
                            "-DENABLE_H263P=YES",
                            "-DENABLE_MPEG4=YES",
                            "-DENABLE_OPENH264=YES"]

    if check_tools() != 0:
        return 1

    if args.tunnel or os.path.isdir("submodules/tunnel"):
        if not os.path.isdir("submodules/tunnel"):
            print("Tunnel wanted but not found yet, trying to clone it...")
            p = Popen("git clone gitosis@git.linphone.org:tunnel.git submodules/tunnel".split(" "))
            p.wait()
            if p.retcode != 0:
                print("Could not clone tunnel. Please see http://www.belledonne-communications.com/voiptunnel.html")
                return 1
        print("Tunnel enabled.")
        additional_args += ["-DENABLE_TUNNEL=YES"]

    # install_git_hook()

    target = DesktopTarget()
    if args.clean:
        target.clean()
        if os.path.isfile('Makefile'):
            os.remove('Makefile')
    else:
        retcode = prepare.run(target, args.debug, False, args.list_cmake_variables, args.force, additional_args)
        if retcode != 0:
            if retcode == 51:
                Popen("make help-prepare-options".split(" "))
                retcode = 0
            return retcode
        #only generated makefile if we are using Ninja or Makefile
        if args.generator.endswith('Ninja'):
            if not check_is_installed("ninja", "it"):
                return 1
            generate_makefile('ninja -C')
            print("You can now run 'make' to build.")
        elif args.generator.endswith("Unix Makefiles"):
            generate_makefile('$(MAKE) -C')
            print("You can now run 'make' to build.")
        elif args.generator == "Xcode":
            print("You can now open Xcode project with: open WORK/cmake/Project.xcodeproj")
        else:
            print("Not generating meta-makefile for generator {}.".format(args.generator))

    return 0

if __name__ == "__main__":
    sys.exit(main())
