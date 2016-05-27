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

import os
import platform
import sys
from logging import error, warning, info
from subprocess import Popen
sys.dont_write_bytecode = True
sys.path.insert(0, 'submodules/cmake-builder')
try:
    import prepare
except Exception as e:
    error(
        "Could not find prepare module: {}, probably missing submodules/cmake-builder? Try running:\n"
        "git submodule sync && git submodule update --init --recursive".format(e))
    exit(1)



class DesktopTarget(prepare.Target):

    def __init__(self, group_builders=False):
        super(DesktopTarget, self).__init__('desktop')
        current_path = os.path.dirname(os.path.realpath(__file__))
        self.config_file = 'configs/config-desktop.cmake'
        self.output = 'OUTPUT/' + self.name
        if platform.system() == 'Windows':
            self.generator = 'Visual Studio 12 2013'
        self.external_source_path = os.path.join(current_path, 'submodules')


class PythonTarget(prepare.Target):

    def __init__(self):
        super(PythonTarget, self).__init__('python')
        current_path = os.path.dirname(os.path.realpath(__file__))
        self.config_file = 'configs/config-python.cmake'
        self.output = 'OUTPUT/' + self.name
        if platform.system() == 'Windows':
            self.generator = 'Visual Studio 9 2008'
        self.external_source_path = os.path.join(current_path, 'submodules')


class PythonRaspberryTarget(prepare.Target):

    def __init__(self):
        super(PythonRaspberryTarget, self).__init__('python-raspberry')
        current_path = os.path.dirname(os.path.realpath(__file__))
        self.required_build_platforms = ['Linux']
        self.config_file = 'configs/config-python-raspberry.cmake'
        self.toolchain_file = 'toolchains/toolchain-raspberry.cmake'
        self.output = 'OUTPUT/' + self.name
        self.external_source_path = os.path.join(current_path, 'submodules')



desktop_targets = {
    'desktop': DesktopTarget(),
    'python': PythonTarget(),
    'python-raspeberry': PythonRaspberryTarget()
}

class DesktopPreparator(prepare.Preparator):

    def __init__(self, targets=desktop_targets, default_targets=['desktop']):
        super(DesktopPreparator, self).__init__(targets, default_targets)
        self.veryclean = True
        self.argparser.add_argument('-ac', '--all-codecs', help="Enable all codecs, including the non-free ones", action='store_true')
        self.argparser.add_argument('-sys', '--use-system-dependencies', help="Find dependencies on the system.", action='store_true')
        self.argparser.add_argument('-p', '--package', help="Build an installation package (only on Mac OSX and Windows).", action='store_true')

    def parse_args(self):
        super(DesktopPreparator, self).parse_args()

        if self.args.use_system_dependencies:
            self.additional_args += ["-DLINPHONE_BUILDER_USE_SYSTEM_DEPENDENCIES=YES"]

        if self.args.all_codecs:
            self.additional_args += ["-DENABLE_GPL_THIRD_PARTIES=YES"]
            self.additional_args += ["-DENABLE_NON_FREE_CODECS=YES"]
            self.additional_args += ["-DENABLE_AMRNB=YES"]
            self.additional_args += ["-DENABLE_AMRWB=YES"]
            self.additional_args += ["-DENABLE_G729=YES"]
            self.additional_args += ["-DENABLE_GSM=YES"]
            self.additional_args += ["-DENABLE_ILBC=YES"]
            self.additional_args += ["-DENABLE_ISAC=YES"]
            self.additional_args += ["-DENABLE_OPUS=YES"]
            self.additional_args += ["-DENABLE_SILK=YES"]
            self.additional_args += ["-DENABLE_SPEEX=YES"]
            self.additional_args += ["-DENABLE_FFMPEG=YES"]
            self.additional_args += ["-DENABLE_H263=YES"]
            self.additional_args += ["-DENABLE_H263P=YES"]
            self.additional_args += ["-DENABLE_MPEG4=YES"]
            self.additional_args += ["-DENABLE_OPENH264=YES"]
            self.additional_args += ["-DENABLE_VPX=YES"]
            self.additional_args += ["-DENABLE_X264=NO"]

        if self.args.package:
            self.additional_args += ["-DENABLE_PACKAGING=YES"]
            self.additional_args += ["-DCMAKE_SKIP_INSTALL_RPATH=YES"]
            self.additional_args += ["-DENABLE_RELATIVE_PREFIX=YES"]

    def clean(self):
        super(DesktopPreparator, self).clean()
        if os.path.isfile('Makefile'):
            os.remove('Makefile')
        if os.path.isdir('WORK') and not os.listdir('WORK'):
            os.rmdir('WORK')
        if os.path.isdir('OUTPUT') and not os.listdir('OUTPUT'):
            os.rmdir('OUTPUT')

    def prepare(self):
        retcode = super(DesktopPreparator, self).prepare()
        if retcode != 0:
            if retcode == 51:
                if os.path.isfile('Makefile'):
                    Popen("make help-prepare-options".split(" "))
                retcode = 0
            return retcode
        # Only generated makefile if we are using Ninja or Makefile
        if self.generator().endswith('Ninja'):
            if not check_is_installed("ninja", "it"):
                return 1
            self.generate_makefile('ninja -C')
            info("You can now run 'make' to build.")
        elif self.generator().endswith("Unix Makefiles"):
            self.generate_makefile('$(MAKE) -C')
            info("You can now run 'make' to build.")
        elif self.generator() == "Xcode":
            info("You can now open Xcode project with: open WORK/cmake/Project.xcodeproj")
        else:
            warning("Not generating meta-makefile for generator {}.".format(self.generator))

    def generate_makefile(self, generator):
        targets = self.args.target
        targets_str = ""
        for target in targets:
            targets_str += """
{target}: {target}-build

{target}-build:
\t{generator} WORK/{target}/cmake
\t@echo "Done"
""".format(target=target, generator=generator)
        makefile = """
targets={targets}

.PHONY: all

all: build

build: $(addsuffix -build, $(targets))

{targets_str}

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
\t@echo "Available targets: {targets}"
\t@echo ""
""".format(targets=' '.join(targets), targets_str=targets_str, options=' '.join(sys.argv), generator=generator)
        f = open('Makefile', 'w')
        f.write(makefile)
        f.close()



def main():
    preparator = DesktopPreparator()
    preparator.parse_args()
    if preparator.check_tools() != 0:
        return 1
    return preparator.run()

if __name__ == "__main__":
    sys.exit(main())
