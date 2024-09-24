# Linphone Desktop

Linphone is an open source softphone for voice and video over IP calling and instant messaging.

It is fully SIP-based, for all calling, presence and IM features.

General description is available from [Linphone web site](https://www.linphone.org/technical-corner/linphone)

### License

Copyright © Belledonne Communications

Linphone is dual licensed, and is available either :

 - under a [GNU/GPLv3 license](https://www.gnu.org/licenses/gpl-3.0.en.html), for free (open source). Please make sure that you understand and agree with the terms of this license before using it (see LICENSE file for details).

 - under a proprietary license, for a fee, to be used in closed source applications. Contact [Belledonne Communications](https://www.linphone.org/contact) for any question about costs and services.

### Documentation

- [Supported features and RFCs](https://www.linphone.org/technical-corner/linphone/features)

- [Linphone public wiki](https://wiki.linphone.org/xwiki/wiki/public/view/Linphone/)


## Getting started

Here are the general instructions to build Linphone for desktop. The specific instructions for each build platform is described just below.
You will need the tools :
- `cmake` >= 3.22 : download it in https://cmake.org/download/
- `python` : https://www.python.org/downloads/release/python-381/
- `pip` : it is already embedded inside Python, so there should be nothing to do about it
- `yasm` : https://yasm.tortall.net/Download.html
- `nasm` : https://www.nasm.us/pub/nasm/releasebuilds/
- `doxygen` (required for the Cxx Wrapper)
- `Perl`
- `pystache` : use 'pip install pystache --user'
- `six` : use 'pip install six --user'
- `git`

For Desktop : you will need [Qt6](https://www.qt.io/download-thank-you) (_6.2 or newer_). `C++17` support is required!

### Set your environment

1. It's necessary to install the `pip` command and to execute:

        pip install pystache six

2. You have to set the environment variable `Qt6_DIR` to point to the path containing the cmake folders of Qt6, and the `PATH` to the Qt6 `bin`. Example:

        Qt6_DIR="~/Qt/6.5.3/gcc_64/lib/cmake/Qt6"
        PATH="~/Qt/6.5.3/gcc_64/bin/:$PATH"

Note: If you have the third party tool `qtchooser` installed : 
        eval "$(qtchooser -print-env)"
        export Qt6_DIR=${QTLIBDIR}/cmake/Qt6
        export PATH=${QTTOOLDIR}:$PATH
3. For specific requirements, see platform instructions sections below.

### Summary of Building steps

        `git clone https://gitlab.linphone.org/BC/public/linphone-desktop.git --recursive`
        `cd linphone-desktop`
        `mkdir build`
        `cd build`
        `cmake .. -DCMAKE_BUILD_PARALLEL_LEVEL=10 -DCMAKE_BUILD_TYPE=RelWithDebInfo`
        `cmake --build . --parallel 10 --config RelWithDebInfo`
        `cmake --install .`
        `./OUTPUT/bin/linphone --verbose` or `./OUTPUT/Linphone.app/Contents/MacOS/linphone --verbose`

### Get sources

        git clone https://gitlab.linphone.org/BC/public/linphone-desktop.git --recursive


### Building : General Steps

The build is done by building the SDK and the application. Their targets are `sdk` and `Linphone`.

1. Create your build folder at the root of the project : `mkdir build`
Go to this new folder and begin the build process : `cd build`

2. Prepare your options : `cmake ..`. By default, it will try compile all needed dependencies. You can remove some by adding `-DENABLE_<COMPONENT>=NO` to the command. You can use `cmake-gui ..` if you want to have a better access to them. You can add `-DCMAKE_BUILD_PARALLEL_LEVEL=<count>` to do `<count>` parallel builds for speeding up the process.
Also, you can add `-DENABLE_BUILD_VERBOSE=ON` to get more feedback while generating the project.

Note : For Makefile or Ninja, you have to add `-DCMAKE_BUILD_TYPE=<your_config>` if you wish to build in a specific configuration (for example `RelWithDebInfo`).

3. Build and install the whole project : `cmake --build . --target <target> --parallel <count>` (replace `<target>` with the target name and `<count>` by the number of parallel builds).

Note : For XCode or Visual Studio, you have to add `--config <your_config>` if you wish to build in a specific configuration (for example `RelWithDebInfo`).

When all are over, the files will be in the OUTPUT folder in the build directory. When rebuilding, you have to use `cmake --build . --target install` (or `cmake --install .`) to put the application in the correct configuration.

Binaries inside other folders (like `build/bin/` and `linphone-sdk`) are not supposed to work.

4. When doing some modifications in the SDK, you can rebuild only the SDK with the target `sdk` and the same for the application with `linphone-qt-only`

5. In order to get packages, you can use `cmake .. -DENABLE_APP_PACKAGING=YES`. The files will be in `OUTPUT/packages` folder.


### Update your project

1. Update your project with :

    git fetch
    git pull --rebase

2. Update sub-modules from your current branch

    git submodule update --init --recursive

Then simply re-build using cmake.


#### General Troubleshooting

* The latest version of Doxygen may not work with the SDK. If you some build issues and have a specific version of Doxygen that is not in your PATH, you can use `-DLINPHONESDK_DOXYGEN_PROGRAM`.

Eg on Mac : `-DLINPHONESDK_DOXYGEN_PROGRAM=/Applications/Doxygen.app/Contents/Resources/doxygen`

* If the build of the SDK crash with something like "cmd.exe failed" and no more info, it can be a dependency that is not available. You have to check if all are in your PATH.
Usually, if it is about VPX or Decaf, this could come from your Perl installation.

* If the application doesn't start and create an empty file with a random name, it could be come from a bad configuration between your application and others sub-modules. Check your configurations and force them with `-DCMAKE_BUILD_TYPE=<your_config>` or `--config <your_config>`.

* On Mac, the application can crash at the start from QOpenGLContext. A workaround is to deactivate the mipmap mode on images by adding into your configuration file (linphonerc): `mipmap_enabled=0` in `[ui]` section.


## Specific instructions for the Mac Os X platform

To install the required dependencies on Mac OS X, you can use [Homebrew](https://brew.sh/).
Before you install packages with Brew, you may have to change directories permissions (if you can't change permissions with sudo on a MacOS >= High Sierra, get a look at [this StackOverflow answer](https://stackoverflow.com/questions/16432071/how-to-fix-homebrew-permissions#46844441)).

1. Install XCode from the Apple store. Run it at least once to allow it to install its tools. You may need to run :

	xcode-select --install

2. Install Homebrew by following the instructions here https://brew.sh/

3. Install dependencies:

    brew install cmake pkg-config git doxygen nasm yasm

4. First ensure you have [pip](https://pypi.org/project/pip/)

5. Then, you can install a pip package with the following command:

    python -m pip install [package]

 For instance, enter the following command:

    python -m pip install pystache six graphviz

6. Download [Qt](https://www.qt.io/download), install a Qt6 version and set Qt6_DIR and PATH variables.

7. If you are building on a arm64 system and want a Intel version, you have to select the x86_64 processor on the generation stage of cmake :

	-DCMAKE_APPLE_SILICON_PROCESSOR=x86_64

8. Build as usual (General Steps).

9. If you get an error about modules that are not found for Python, it may be because cmake try to use another version from your PATH. It can be the case if you installed Python from brew. Install Python modules by using absolute path.
For example:

	/opt/homebrew/python3 -m pip install pystache six graphviz

## Specific instructions for the Windows platform

32-bit version is not supported as Qt6 doesn't provide 32bits packages for MSVC.
Visual Studio 2022 is only supported.

1. Install main tools:
  - `MinGW/MSYS2` : [download](https://www.msys2.org/)
    - Follow instructions on their "Getting Started" page.
    - Install toolchains and prepare python:
      - `pacman -Sy --needed base-devel mingw-w64-mingw64-toolchain`
      - `pacman -S python3-pip` in `MSYS2 MSYS` console
      - `python3 -m pip install pystache six` in `cmd`
      - In this order, add `C:\msys64\mingw64\bin`, `C:\msys64\` and `C:\msys64\usr\bin` in your PATH environement variable from Windows advanced settings. Binaries from the msys folder (not from mingw64) doesn't fully support Windows Path and thus, they are to be avoided.

Specify `-DENABLE_WINDOWS_TOOLS_CHECK=ON` when building the SDK to install automatically missing tools from MSYS2 : `toolchain`, `python`, `doxygen`, `perl`, `yasm`, `gawk`, `bzip2`, `nasm`, `sed`, `patch`, `pkg-config`, `gettext`, `glib2`, `intltool` and `graphviz` (if needed)

  - `git` : use MSYS2 : `pacman -S git` or [download](https://git-scm.com/download/win)

  - Visual Studio must also be properly configured with addons. Under "Tools"->"Obtain tools and features", make sure that the following components are installed:
    - Select Windows Universal Platform development and Desktop C++ Development

2. Ensure that you have downloaded the correct Qt version on msvc.

3. Or open a Command line with Visual Studio `Developer Command Prompt for VS 2022` and call qtenv2.bat that is in your qt binaries eg: `C:\Qt\<version>\msvc2019\bin\qtenv2.bat`

4. Build as usual with adding `-A x64` to `cmake ..` (General Steps) :
  - `cmake .. -DCMAKE_BUILD_PARALLEL_LEVEL=10 -DCMAKE_BUILD_TYPE=RelWithDebInfo -A x64`
The default build is very long. It is prefered to use the Ninja generator `-G "Ninja"`
  - `cmake --build . --target ALL_BUILD --parallel 10 --config RelWithDebInfo`

5. The project folder will be in the build directory and binaries should be in the OUTPUT folder.

## Specific instructions for Linux

sudo apt install qt6-base-dev

In case of 'module "QtQuick.\*" is not installed' error, you may install these packages:
  - qml-qt6
  - qml6-module-qtquick
  - qml6-module-qtquick-layouts
  - qml6-module-qtqml-workerscript
  - qml6-module-qtquick-controls
  - qml6-module-qtquick-templates

## Installing dependencies

There are [docker files](docker-files) configurations where dependencies can be retrieved.

Also, more configurations are available in the docker-files folder of linphone-sdk submodule.

## Options


| Options | Description | Default value |
| :--- | :---: | ---: |
| ENABLE_APP_LICENSE | Enable the license in packages. | YES |
| ENABLE_APP_PACKAGING | Enable packaging. Package will be deployed in `OUTPUT/packages` | NO |
| ENABLE_APP_PDF_VIEWER | Enable PDF viewer. Need Qt PDF module. | YES |
| ENABLE_APP_WEBVIEW | Enable webview for accounts. The Webview engine must be deployed, it takes a large size. | NO |
| ENABLE_APP_PACKAGE_ROOTCA | Embed the rootca file (concatenation of all root certificates published by mozilla) into the package | YES |
| ENABLE_BUILD_APP_PLUGINS | Enable the build of plugins | YES |
| ENABLE_BUILD_EXAMPLES | Enable the build of examples | NO |
| ENABLE_BUILD_VERBOSE | Enable the build generation to be more verbose | NO |
| ENABLE_DAEMON | Enable the linphone daemon interface. | NO |
| ENABLE_PQCRYPTO | Enable post quantum ZRTP. | NO |
| ENABLE_STRICT | Build with strict compilator flags e.g. -Wall -Werror | NO |
| ENABLE_TESTS | Build with testing binaries of SDK | NO |
| ENABLE_TESTS_COMPONENTS | Build libbctoolbox-tester | NO |
| ENABLE_TOOLS | Enable tools of SDK | NO |
| ENABLE_UNIT_TESTS | Enable unit test of SDK. | NO |
| ENABLE_UPDATE_CHECK | Enable update check. | YES |
| LINPHONE_SDK_MAKE_RELEASE_FILE_URL | Make a RELEASE file that work along check_version and use this URL | "" |


<!-- Not customizable without warranty
| ENABLE_LDAP | Enable LDAP support. | YES |
| ENABLE_VIDEO | Enable Video support. | YES |
| ENABLE_OPENH264 | Enable the use of OpenH264 codec | YES |
| ENABLE_NON_FREE_FEATURES | Enable the use of non free features | YES |
| ENABLE_FFMPEG | Build mediastreamer2 with ffmpeg video support. | NO |
| ENABLE_CONSOLE_UI | Turn on or off compilation of console interface. | NO |
-->

## Contributing

### Code

In order to submit a patch for inclusion in Linphone's source code:

1. First make sure that your patch applies to the latest Git sources before submitting : patches made to old versions can't and won't be merged.

2. Fill out and send the contributor agreement for your patch to be included in the Git tree by following links [there](https://www.linphone.org/contact). The goal of this agreement is to grant us the peaceful exercise of our rights to the Linphone source code, without losing your rights over your contribution.

3. Then go to the [github repository](https://github.com/BelledonneCommunications/linphone-desktop/pulls) and make a Pull Requests based on your code.

Please note that we don't offer free support and these contributions will be addressed on our free-time.

<a href="https://weblate.linphone.org/engage/linphone-desktop/?utm_source=widget">
<img src="https://weblate.linphone.org/widgets/linphone-desktop/-/multi-auto.svg" alt="Translation status" align="right"/>
</a>

#### Files tree

- Linphone : Application code.
	- model : SDK management that is run on the SDK thread.
	- view: GUI stuff that is run on UI thread.
		- Item: simple base items that overload existant simple object.
		- Page: Use of Items for more complexe features.
		- Tool: JS tools and codes.
		- App: Application flow that manage Pages.
			
	- core: Main code that link model and view in a MVVM pattern.
	- data: all data that is not code
		- conf: configuration files
		- font: embedded fonts
		- icon: generated icons
		- image: all images of the application. The format should be in svg and in monocolor to allow realtime updates.
		- lang: TS files used with Weblate.
	- tool: internal library for generic tools.

- cmake : Build and Installation scripts.

- external : external projects.
	- linphone-sdk

### Languages


<br />
Linphone is getting a full internationalization support.<br />
<br />
We no longer use transifex for the translation process, instead we have deployed our own instance of [Weblate](https://weblate.linphone.org).<br />
<br />
<br />
If you would like to contribute, you could do it at : https://weblate.linphone.org/projects/linphone-desktop/

<br />
<br />
<br />
<br />

### Feedback or bug reporting

Launch the application with `--verbose` parameter to get full logs and send it with your request. You can use the "Send logs" button in settings to upload log files and share it by email or with a post in the corresponding Github project :
- [Desktop Application](https://github.com/BelledonneCommunications/linphone-desktop/issues)
- [Linphone SDK](https://github.com/BelledonneCommunications/linphone-sdk/issues)

On some OS (like Fedora 22 and later), they disable Qt debug output by default. To get full output, you need to create `~/.config/QtProject/qtlogging.ini` and add :

        [Rules]
        *.debug=true
        qt.*.debug=false
