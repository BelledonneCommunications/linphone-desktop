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
sys.path.insert(0, 'cmake-builder')
try:
    import prepare
except:
    print("Could not find prepare module, probably missing cmake-builder? Try running: git submodule update --init --recursive")
    exit(1)


class DesktopTarget(prepare.Target):

    def __init__(self):
        prepare.Target.__init__(self, '')
        current_path = os.path.dirname(os.path.realpath(__file__))
        self.config_file = 'configs/config-desktop.cmake'
        self.additional_args = [
            '-DLINPHONE_BUILDER_EXTERNAL_SOURCE_PATH=' + current_path
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

    # for prog in ["autoconf", "automake", "pkg-config", "doxygen", "java", "nasm", "cmake", "wget", "yasm", "optipng"]:
    #     ret |= not check_is_installed(prog, "it")
    # ret |= not check_is_installed("ginstall", "coreutils")
    # ret |= not check_is_installed("intltoolize", "intltool")
    # ret |= not check_is_installed("convert", "imagemagick")

    # if not check_is_installed("libtoolize", warn=False):
    #     if check_is_installed("glibtoolize", "libtool"):
    #         glibtoolize_path = find_executable(glibtoolize)
    #         ret = 1
    #         error = "Please do a symbolic link from glibtoolize to libtoolize: 'ln -s {} ${}'."
    #         print(error.format(glibtoolize_path, glibtoolize_path.replace("glibtoolize", "libtoolize")))

    # devnull = open(os.devnull, 'wb')
    # # just ensure that JDK is installed - if not, it will automatiaclyl display a popup to user
    # p = Popen("java -version".split(" "), stderr=devnull, stdout=devnull)
    # p.wait()
    # if p.returncode != 0:
    #     print(p.returncode)
    #     print("Please install Java JDK (not just JRE).")
    #     ret = 1

    # # needed by x264
    # check_is_installed("gas-preprocessor.pl", """it:
    #     wget --no-check-certificate https://raw.github.com/yuvi/gas-preprocessor/master/gas-preprocessor.pl
    #     chmod +x gas-preprocessor.pl
    #     sudo mv gas-preprocessor.pl /usr/local/bin/""")

    # nasm_output = Popen("nasm -f elf32".split(" "), stderr=PIPE, stdout=PIPE).stderr.read()
    # if "fatal: unrecognised output format" in nasm_output:
    #     print(
    #         "Invalid version of nasm: your version does not support elf32 output format. If you have installed nasm, please check that your PATH env variable is set correctly.")
    #     ret = 1

    #     if not os.path.isdir("submodules/linphone/mediastreamer2") or not os.path.isdir("submodules/linphone/oRTP"):
    #         print("Missing some git submodules. Did you run 'git submodule update --init --recursive'?")
    #         ret = 1
    # p = Popen("xcrun --sdk iphoneos --show-sdk-path".split(" "), stdout=devnull, stderr=devnull)
    # p.wait()
    # if p.returncode != 0:
    #     print("iOS SDK not found, please install Xcode from AppStore or equivalent.")
    #     ret = 1
    # else:
    #     sdk_platform_path = Popen("xcrun --sdk iphonesimulator --show-sdk-platform-path".split(" "), stdout=PIPE, stderr=devnull).stdout.read()[:-1]
    #     sdk_strings_path = "{}/{}".format(sdk_platform_path, "Developer/usr/bin/strings")
    #     if not os.path.isfile(sdk_strings_path):
    #         strings_path = find_executable("strings")
    #         print("strings binary missing, please run 'sudo ln -s {} {}'.".format(strings_path, sdk_strings_path))
    #         ret = 1

    # if ret == 1:
    #     print("Failed to detect required tools, aborting.")

    return ret


# def install_git_hook():
    # git_hook_path = ".git{sep}hooks{sep}pre-commit".format(sep=os.sep)
    # if os.path.isdir(".git{sep}hooks".format(sep=os.sep)) and not os.path.isfile(git_hook_path):
    #     print("Installing Git pre-commit hook")
    #     shutil.copyfile(".git-pre-commit", git_hook_path)
    #     os.chmod(git_hook_path, 0755)


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
\tif ! grep -q " $* " <<< " $(packages) "; then \\
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
        '-G' '--generator', help="CMake build system generator (default: Unix Makefiles).", default='Unix Makefiles', choices=['Unix Makefiles', 'Ninja'])
    argparser.add_argument(
        '-L', '--list-cmake-variables', help="List non-advanced CMake cache variables.", action='store_true', dest='list_cmake_variables')
    argparser.add_argument(
        '-m', '--minimal', help="Build a minimal version of Linphone.", action='store_true')
    argparser.add_argument(
        '-t', '--tunnel', help="Enable Tunnel.", action='store_true')

    args, additional_args = argparser.parse_known_args()

    additional_args += ["-DLINPHONE_BUILDER_BUILD_DEPENDENCIES=NO"]
    if args.debug_verbose:
        additional_args += ["-DENABLE_DEBUG_LOGS=YES"]

    if args.minimal:
        additional_args += ["-DENABLE_AMRNB=NO"]
        additional_args += ["-DENABLE_AMRWB=NO"]
        additional_args += ["-DENABLE_DOC=NO"]
        additional_args += ["-DENABLE_G729=NO"]
        additional_args += ["-DENABLE_GSM=NO"]
        additional_args += ["-DENABLE_H263=NO"]
        additional_args += ["-DENABLE_H263P=NO"]
        additional_args += ["-DENABLE_ILBC=NO"]
        additional_args += ["-DENABLE_ISAC=NO"]
        additional_args += ["-DENABLE_MPEG4=NO"]
        additional_args += ["-DENABLE_OPENH264=NO"]
        additional_args += ["-DENABLE_OPUS=NO"]
        additional_args += ["-DENABLE_PACKAGING=NO"]
        additional_args += ["-DENABLE_SILK=NO"]
        additional_args += ["-DENABLE_SRTP=NO"]
        additional_args += ["-DENABLE_VPX=NO"]
        additional_args += ["-DENABLE_WASAPI=NO"]
        additional_args += ["-DENABLE_ZRTP=NO"]

    if check_tools() != 0:
        return 1

    if args.tunnel:
        if not os.path.isdir("tunnel"):
            print("Tunnel enabled but not found, trying to clone it...")
            if check_is_installed("git", "it", True):
                Popen("git clone gitosis@git.linphone.org:tunnel.git submodules/tunnel".split(" ")).wait()
            else:
                return 1
        additional_args += ["-DENABLE_TUNNEL=YES"]

    additional_args += ["-G", args.G__generator]
    if args.G__generator == 'Ninja':
        if not check_is_installed("ninja", "it"):
            return 1
        generator = 'ninja -C'
    else:
        generator = '$(MAKE) -C'

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
        generate_makefile(generator)

    return 0

if __name__ == "__main__":
    sys.exit(main())
