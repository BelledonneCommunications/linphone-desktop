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
from logging import error, warning, info, INFO, basicConfig
from subprocess import Popen
from distutils.spawn import find_executable
sys.dont_write_bytecode = True
sys.path.insert(0, 'submodules/cmake-builder')
try:
    import prepare
except Exception as e:
    error(
        "Could not find prepare module: {}, probably missing submodules/cmake-builder? Try running:\ngit submodule update --init --recursive".format(e))
    exit(1)


class DesktopTarget(prepare.Target):

    def __init__(self):
        prepare.Target.__init__(self, '')
        current_path = os.path.dirname(os.path.realpath(__file__))
        if platform.system() == 'Windows':
            current_path = current_path.replace('\\', '/')
        self.config_file = 'configs/config-desktop.cmake'
        if platform.system() == 'Windows':
            self.generator = 'Visual Studio 12 2013'
        self.additional_args = [
            '-DCMAKE_INSTALL_MESSAGE=LAZY',
            '-DLINPHONE_BUILDER_EXTERNAL_SOURCE_PATH=' + current_path + '/submodules',
            '-DLINPHONE_BUILDER_GROUP_EXTERNAL_SOURCE_PATH_BUILDERS=YES'
        ]


class PythonTarget(prepare.Target):

    def __init__(self):
        prepare.Target.__init__(self, '')
        current_path = os.path.dirname(os.path.realpath(__file__))
        if platform.system() == 'Windows':
            current_path = current_path.replace('\\', '/')
        self.config_file = 'configs/config-python.cmake'
        if platform.system() == 'Windows':
            self.generator = 'Visual Studio 9 2008'
        self.additional_args = [
            '-DCMAKE_INSTALL_MESSAGE=LAZY',
            '-DLINPHONE_BUILDER_EXTERNAL_SOURCE_PATH=' + current_path + '/submodules',
            '-DLINPHONE_BUILDER_GROUP_EXTERNAL_SOURCE_PATH_BUILDERS=YES'
        ]


class PythonRaspberryTarget(prepare.Target):

    def __init__(self):
        prepare.Target.__init__(self, '')
        current_path = os.path.dirname(os.path.realpath(__file__))
        self.required_build_platforms = ['Linux']
        self.config_file = 'configs/config-python-raspberry.cmake'
        self.toolchain_file = 'toolchains/toolchain-raspberry.cmake'
        self.additional_args = [
            '-DCMAKE_INSTALL_MESSAGE=LAZY',
            '-DLINPHONE_BUILDER_EXTERNAL_SOURCE_PATH=' + current_path + '/submodules',
            '-DLINPHONE_BUILDER_GROUP_EXTERNAL_SOURCE_PATH_BUILDERS=YES'
        ]


def check_is_installed(binary, prog='it', warn=True):
    if not find_executable(binary):
        if warn:
            error("Could not find {}. Please install {}.".format(binary, prog))
        return False
    return True


def check_tools():
    ret = 0

    #at least FFmpeg requires no whitespace in sources path...
    if " " in os.path.dirname(os.path.realpath(__file__)):
        error("Invalid location: path should not contain any spaces.")
        ret = 1

    ret |= not check_is_installed('cmake')

    if not os.path.isdir("submodules/linphone/mediastreamer2/src") or not os.path.isdir("submodules/linphone/oRTP/src"):
        error("Missing some git submodules. Did you run:\n\tgit submodule update --init --recursive")
        ret = 1

    return ret


def generate_makefile(generator):
    makefile = """
.PHONY: all

build:
\t{generator} WORK/cmake

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
\t@echo ""
""".format(options=' '.join(sys.argv), generator=generator)
    f = open('Makefile', 'w')
    f.write(makefile)
    f.close()


def main(argv=None):
    basicConfig(format="%(levelname)s: %(message)s", level=INFO)

    if argv is None:
        argv = sys.argv
    argparser = argparse.ArgumentParser(
        description="Prepare build of Linphone and its dependencies.")
    argparser.add_argument(
        '-ac', '--all-codecs', help="Enable all codecs, including the non-free ones", action='store_true')
    argparser.add_argument(
        '-c', '--clean', help="Clean a previous build instead of preparing a build.", action='store_true')
    argparser.add_argument(
        '-C', '--veryclean', help="Clean a previous build instead of preparing a build (also deleting the install prefix).", action='store_true')
    argparser.add_argument(
        '-d', '--debug', help="Prepare a debug build, eg. add debug symbols and use no optimizations.", action='store_true')
    argparser.add_argument(
        '-f', '--force', help="Force preparation, even if working directory already exist.", action='store_true')
    argparser.add_argument(
        '-G', '--generator', help="CMake build system generator (default: let CMake choose, use cmake -h to get the complete list).", default=None, dest='generator')
    argparser.add_argument(
        '-L', '--list-cmake-variables', help="List non-advanced CMake cache variables.", action='store_true', dest='list_cmake_variables')
    argparser.add_argument(
        '-os', '--only-submodules', help="Build only submodules (finding all dependencies on the system.", action='store_true')
    argparser.add_argument(
        '-p', '--package', help="Build an installation package (only on Mac OSX and Windows).", action='store_true')
    argparser.add_argument(
        '--python', help="Build Python module instead of desktop application.", action='store_true')
    argparser.add_argument(
        '--python-raspberry', help="Build Python module for raspberry pi instead of desktop application.", action='store_true')
    argparser.add_argument(
        '-t', '--tunnel', help="Enable Tunnel.", action='store_true')

    args, additional_args = argparser.parse_known_args()

    if args.only_submodules:
        additional_args += ["-DLINPHONE_BUILDER_BUILD_ONLY_EXTERNAL_SOURCE_PATH=YES"]

    if args.all_codecs:
        additional_args += ["-DENABLE_GPL_THIRD_PARTIES=YES"]
        additional_args += ["-DENABLE_NON_FREE_CODECS=YES"]
        additional_args += ["-DENABLE_AMRNB=YES"]
        additional_args += ["-DENABLE_AMRWB=YES"]
        additional_args += ["-DENABLE_G729=YES"]
        additional_args += ["-DENABLE_GSM=YES"]
        additional_args += ["-DENABLE_ILBC=YES"]
        additional_args += ["-DENABLE_ISAC=YES"]
        additional_args += ["-DENABLE_OPUS=YES"]
        additional_args += ["-DENABLE_SILK=YES"]
        additional_args += ["-DENABLE_SPEEX=YES"]
        additional_args += ["-DENABLE_FFMPEG=YES"]
        additional_args += ["-DENABLE_H263=YES"]
        additional_args += ["-DENABLE_H263P=YES"]
        additional_args += ["-DENABLE_MPEG4=YES"]
        additional_args += ["-DENABLE_OPENH264=YES"]
        additional_args += ["-DENABLE_VPX=YES"]
        additional_args += ["-DENABLE_X264=NO"]

    if args.package:
        additional_args += ["-DENABLE_PACKAGING=YES"]
        if platform.system() != 'Windows':
            additional_args += ["-DENABLE_RELATIVE_PREFIX=YES"] # Already forced in all cases on Windows platform
    if check_tools() != 0:
        return 1

    if args.tunnel or os.path.isdir("submodules/tunnel"):
        if not os.path.isdir("submodules/tunnel"):
            info("Tunnel wanted but not found yet, trying to clone it...")
            p = Popen("git clone gitosis@git.linphone.org:tunnel.git submodules/tunnel".split(" "))
            p.wait()
            if p.returncode != 0:
                error("Could not clone tunnel. Please see http://www.belledonne-communications.com/voiptunnel.html")
                return 1
        info("Tunnel enabled.")
        additional_args += ["-DENABLE_TUNNEL=YES"]

    # install_git_hook()

    target = None

    if args.python:
        target = PythonTarget()
    elif args.python_raspberry:
        target = PythonRaspberryTarget()
    else:
        target = DesktopTarget()
    if args.generator is not None:
        target.generator = args.generator
    if target.generator is None:
        # Default to "Unix Makefiles" if no target specific generator is set and the user has not defined one
        target.generator = "Unix Makefiles"

    if args.clean or args.veryclean:
        if args.veryclean:
            target.veryclean()
        else:
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
        # only generated makefile if we are using Ninja or Makefile
        if target.generator.endswith('Ninja'):
            if not check_is_installed("ninja", "it"):
                return 1
            generate_makefile('ninja -C')
            info("You can now run 'make' to build.")
        elif target.generator.endswith("Unix Makefiles"):
            generate_makefile('$(MAKE) -C')
            info("You can now run 'make' to build.")
        elif target.generator == "Xcode":
            info("You can now open Xcode project with: open WORK/cmake/Project.xcodeproj")
        else:
            warning("Not generating meta-makefile for generator {}.".format(target.generator))

    return 0

if __name__ == "__main__":
    sys.exit(main())
