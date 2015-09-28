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
    packages = os.listdir('WORK/Build')
    packages.sort()
    makefile = """
packages={packages}

.PHONY: all

build:
\t@for package in $(packages); do \\
\t\t$(MAKE) build-$$package; \\
\tdone

clean:
\t@for package in $(packages); do \\
\t\t$(MAKE) clean-$$package; \\
\tdone

veryclean:
\t@for package in $(packages); do \\
\t\t$(MAKE) veryclean-$$package; \\
\tdone

build-%: package-in-list-%
\techo "==== starting build of $* ===="; \\
\trm -f WORK/Stamp/EP_$*/EP_$*-update; \\
\t{generator} WORK/cmake EP_$*

clean-%: package-in-list-%
\techo "==== starting clean of $* ===="; \\
\t{generator} WORK/Build/$* clean; \\
\trm -f WORK/Stamp/EP_$*/EP_$*-build; \\
\trm -f WORK/Stamp/EP_$*/EP_$*-install;

veryclean-%: package-in-list-%
\techo "==== starting veryclean of $* ===="; \\
\ttest -f WORK/Build/$*/install_manifest.txt && \\
\tcat WORK/Build/$*/install_manifest.txt | xargs rm; \\
\trm -rf WORK/Build/$*/*; \\
\trm -f WORK/Stamp/EP_$*/*; \\
\techo "Run 'make build-$*' to rebuild $* correctly.";

all: build

all-%:
\t@for package in $(packages); do \\
\t\trm -f WORK/ios-$*/Stamp/EP_$$package/EP_$$package-update; \\
\tdone
\t{generator} WORK/ios-$*/cmake

package-in-list-%:
\tif ! echo " $(packages) " | grep -q " $* "; then \\
\t\techo "$* not in list of available packages: $(packages)"; \\
\t\texit 3; \\
\tfi

build:$(addprefix build-,$(packages))
clean: $(addprefix clean-,$(packages))
veryclean: $(addprefix veryclean-,$(packages))

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
\t@echo "Available packages: {packages}"
\t@echo ""
\t@echo "Available targets:"
\t@echo ""
\t@echo "   * all                 : builds all packages"
\t@echo "   * build-[package]     : builds a package"
\t@echo "   * clean-[package]     : clean the package compilation residuals"
\t@echo "   * veryclean-[package] : remove anything related to the package"
\t@echo ""
""".format(options=' '.join(sys.argv), packages=' '.join(packages), generator=generator)
    f = open('Makefile', 'w')
    f.write(makefile)
    f.close()


def main(argv=None):
    if argv is None:
        argv = sys.argv
    argparser = argparse.ArgumentParser(
        description="Prepare build of Linphone and its dependencies.")
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
        '-t', '--tunnel', help="Enable Tunnel.", action='store_true')

    args, additional_args = argparser.parse_known_args()

    additional_args += ["-G", args.generator]

    if args.debug_verbose:
        additional_args += ["-DENABLE_DEBUG_LOGS=YES"]

    if args.minimal:
        additional_args = ["-DLINPHONE_BUILDER_BUILD_DEPENDENCIES=NO",
                           "-DENABLE_AMRNB=NO",
                           "-DENABLE_AMRWB=NO",
                           "-DENABLE_DOC=NO",
                           "-DENABLE_G729=NO",
                           "-DENABLE_GSM=NO",
                           "-DENABLE_H263=NO",
                           "-DENABLE_H263P=NO",
                           "-DENABLE_ILBC=NO",
                           "-DENABLE_ISAC=NO",
                           "-DENABLE_MKV=NO",
                           "-DENABLE_MPEG4=NO",
                           "-DENABLE_OPENH264=NO",
                           "-DENABLE_OPUS=NO",
                           "-DENABLE_PACKAGING=NO",
                           "-DENABLE_SILK=NO",
                           "-DENABLE_SRTP=NO",
                           "-DENABLE_VPX=NO",
                           "-DENABLE_WASAPI=NO",
                           "-DENABLE_ZRTP=NO"] + additional_args

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
        additional_args += ["-DENABLE_TUNNEL=ON"]

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
        if args.generator == 'Ninja':
            if not check_is_installed("ninja", "it"):
                return 1
            generate_makefile('ninja -C')
        elif args.generator == "Unix Makefiles":
            generate_makefile('$(MAKE) -C')
        elif args.generator == "Xcode":
            print("You can now open Xcode project with: open WORK/cmake/Project.xcodeproj")
        else:
            print("Not generating meta-makefile for generator {}.".format(args.generator))

    return 0

if __name__ == "__main__":
    sys.exit(main())
