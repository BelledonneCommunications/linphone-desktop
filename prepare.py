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
        prepare.Target.__init__(self, 'desktop')
        current_path = os.path.dirname(os.path.realpath(__file__))
        self.config_file = 'configs/config-desktop.cmake'
        self.output = 'OUTPUT/' + self.name
        if platform.system() == 'Windows':
            self.generator = 'Visual Studio 12 2013'
        self.external_source_path = os.path.join(current_path, 'submodules')


class PythonTarget(prepare.Target):

    def __init__(self):
        prepare.Target.__init__(self, 'python')
        current_path = os.path.dirname(os.path.realpath(__file__))
        self.config_file = 'configs/config-python.cmake'
        self.output = 'OUTPUT/' + self.name
        if platform.system() == 'Windows':
            self.generator = 'Visual Studio 9 2008'
        self.external_source_path = os.path.join(current_path, 'submodules')


class PythonRaspberryTarget(prepare.Target):

    def __init__(self):
        prepare.Target.__init__(self, 'python-raspberry')
        current_path = os.path.dirname(os.path.realpath(__file__))
        self.required_build_platforms = ['Linux']
        self.config_file = 'configs/config-python-raspberry.cmake'
        self.toolchain_file = 'toolchains/toolchain-raspberry.cmake'
        self.output = 'OUTPUT/' + self.name
        self.external_source_path = os.path.join(current_path, 'submodules')



desktop_targets = {
    'desktop': DesktopTarget(),
    'python': PythonTarget(),
    'python-raspberry': PythonRaspberryTarget()
}

class DesktopPreparator(prepare.Preparator):

    def __init__(self, targets=desktop_targets, default_targets=['desktop']):
        prepare.Preparator.__init__(self, targets, default_targets)
        self.veryclean = True
        self.argparser.add_argument('-ac', '--all-codecs', help="Enable all codecs, including the non-free ones", action='store_true')
        self.argparser.add_argument('-sys', '--use-system-dependencies', help="Find dependencies on the system.", action='store_true')
        self.argparser.add_argument('-p', '--package', help="Build an installation package (only on Mac OSX and Windows).", action='store_true')

    def parse_args(self):
        prepare.Preparator.parse_args(self)

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
        prepare.Preparator.clean(self)
        if os.path.isfile('Makefile'):
            os.remove('Makefile')
        if os.path.isdir('WORK') and not os.listdir('WORK'):
            os.rmdir('WORK')
        if os.path.isdir('OUTPUT') and not os.listdir('OUTPUT'):
            os.rmdir('OUTPUT')

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
        preparator.show_missing_dependencies()
        return 1
    return preparator.run()

if __name__ == "__main__":
    sys.exit(main())
