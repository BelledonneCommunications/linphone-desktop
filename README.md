[![pipeline status](https://gitlab.linphone.org/BC/public/linphone-desktop/badges/master/pipeline.svg)](https://gitlab.linphone.org/BC/public/linphone-desktop/commits/master)

# Linphone Desktop

Linphone is an open source softphone for voice and video over IP calling and instant messaging.

It is fully SIP-based, for all calling, presence and IM features.

General description is available from [linphone web site](https://www.linphone.org/technical-corner/linphone)

### License

Copyright © Belledonne Communications

Linphone is dual licensed, and is available either :

 - under a [GNU/GPLv3 license](https://www.gnu.org/licenses/gpl-3.0.en.html), for free (open source). Please make sure that you understand and agree with the terms of this license before using it (see LICENSE file for details).

 - under a proprietary license, for a fee, to be used in closed source applications. Contact [Belledonne Communications](https://www.linphone.org/contact) for any question about costs and services.

### Documentation

- Supported features and RFCs : https://www.linphone.org/technical-corner/linphone/features

- Linphone public wiki : https://wiki.linphone.org/xwiki/wiki/public/view/Linphone/

## Getting started

Here are the general instructions to build linphone for desktop. The specific instructions for each build platform is described just below.
You will need the tools defined for Linphone-SDK 4.3 :
- cmake >= 3.6
- python = 2.7 (python 3.7 if C# wrapper generation is disabled)
- pip
- yasm
- nasm
- doxygen (required for the Cxx Wrapper)
- Pystache (use pip install pystache)
- six (use pip install six)
- Perl (can be downloaded at http://strawberryperl.com/ for Windows. Set your Path to perl binaries)

For Desktop : you will need `Qt5` (_5.9 or newer_). `C++11` support is required!

### Set your environment


1. It's necessary to install the `pip` command and to execute:

        pip install pystache

2. You have to set the environment variable `Qt5_DIR` to point to the path containing the cmake folders of Qt5, and the `PATH` to the Qt5 `bin`. Example:

        Qt5_DIR="~/Qt/5.9/gcc_64/lib/cmake"
        PATH="~/Qt/5.9/gcc_64/bin/:$PATH"

Note: If you have `qtchooser` set in your `PATH`, the best use is :

        eval "$(qtchooser -print-env)"
        export Qt5_DIR=${QTLIBDIR}/cmake/Qt5
        export PATH=${QTTOOLDIR}:$PATH

		
### Building

The build is done in 3 steps. First, you need to build the SDK, then the submodule Minizip and finally, the application.

1. Create your build folder at the root of the project : `mkdir build-desktop`
Go to this new folder and begin the build process : `cd build-desktop`

2. Prepare your options : `cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo` By default, it will try compile all dependencies. You can remove some by adding `-DENABLE_<COMPONENT>=NO` to the command. You can use `cmake-gui ..` if you want to have a better access to them.

3. Build the SDK : `cmake --build . --target sdk --config RelWithDebInfo`. You can add `--parallel 10` if you have CMake>3.12 to speedup the process.

4. Build The submodule. `cmake ..` and `cmake --build . --target install --config RelWithDebInfo`

If the target install doesn't exist, it is because you had issues on the first step or the project generation could be done when calling `cmake ..`.

5. Finish the process with a new `cmake ..` and `cmake --build . --target install --config RelWithDebInfo`.

It is important to set the config in the process or you can have a bad configuration for your binary that could lead to some corruption : on Windows, this issue is spotted when trying to start the application and an empty file with a random name is created. So, you are working on an IDE (like Qt Creator), you may override the build command.

When all are over, the files will be in the OUTPUT folder in the build directory.

You can find a script file for each supported platform to achieve the first building. They only exist for convenience.
There are called `build_all_linux.sh`, `build_all_macos.sh` and `build_all_win.bat`.

#### General Troubleshooting

* The latest version of Doxygen doesn't work with the SDK. If you have a specific version of Doxygen that is not in your PATH, you can use `-DLINPHONESDK_DOXYGEN_PROGRAM`.

Eg on Mac : `-DLINPHONESDK_DOXYGEN_PROGRAM=/Applications/Doxygen.app/Contents/Resources/doxygen`

* If the build of the SDK crash with something like "cmd.exe failed" and no more info, it can be a dependency that is not available. You have to check if all are in your PATH.
Usually, if it is about VPX or Decaf, this could come from your Perl installation. 



#### Mac OS X Troubleshooting
To install the required dependencies on Mac OS X, you can use [Homebrew](https://brew.sh/).
Before you install packages with Brew, you may have to change directories permissions (if you can't change permissions with sudo on a MacOS >= High Sierra, get a look at [this StackOverflow answer](https://stackoverflow.com/questions/16432071/how-to-fix-homebrew-permissions#46844441)).

1. First ensure you have installed pip. You can get it for python 2.7 [there](https://stackoverflow.com/questions/34886101/how-to-install-pip-to-python-2-7-10-on-mac#34886254).

2. Then, you can install a pip package with the following command:

        pip install [package]

    For instance, if you don't have pystache and the dot package (contained in graphviz), enter the following commands:

        pip install pystache
        pip install graphviz


### Specific instructions for the Windows platform

1. Ensure that you have downloaded the `Qt msvc2015 version` or `Qt msvc2017 version` (32-bit). (64-bit version is not supported at this moment by Linphone Desktop.) `MinGW` must be installed too.

2. Define the `Qt5_DIR` and `PATH` environment variable to the Qt5 installation path:

        Qt5_DIR="C:\Qt\<version>\msvc2017\lib\cmake"
        PATH="C:\Qt\<version>\msvc2017\bin;%PATH%"

2. Or open a Command line with Visual Studio `Developer Comand Prompt for VS 2017` and call qtenv2.bat that is in your qt binaries eg: C:\Qt\5.12.6\msvc2017\bin\qtenv2.bat

3. Install msys-coreutils : `mingw-get install msys-coreutils`

4. Build as usual with adding `-A Win32` to each command (General Steps)

5. The project folder will be in the build directory.

### Installing Linux dependencies


Dependencies from 4.1 version of Desktop:

apt-get install libqt53dcore5:amd64 libqt53dextras5:amd64 libqt53dinput5:amd64 libqt53dlogic5:amd64 libqt53dquick5:amd64 libqt53dquickextras5:amd64 libqt53dquickinput5:amd64 libqt53dquickrender5:amd64  libqt53drender5:amd64 libqt5concurrent5:amd64 libqt5core5a:amd64 libqt5dbus5:amd64 libqt5designer5:amd64 libqt5designercomponents5:amd64 libqt5gui5:amd64 libqt5help5:amd64 libqt5multimedia5:amd64 libqt5multimedia5-plugins:amd64 libqt5multimediawidgets5:amd64 libqt5network5:amd64 libqt5opengl5:amd64 libqt5opengl5-dev:amd64 libqt5positioning5:amd64 libqt5printsupport5:amd64 libqt5qml5:amd64 libqt5quick5:amd64 libqt5quickcontrols2-5:amd64 libqt5quickparticles5:amd64 libqt5quicktemplates2-5:amd64 libqt5quicktest5:amd64 libqt5quickwidgets5:amd64 libqt5script5:amd64 libqt5scripttools5:amd64 libqt5sensors5:amd64 libqt5serialport5:amd64 libqt5sql5:amd64 libqt5sql5-sqlite:amd64 libqt5svg5:amd64 libqt5svg5-dev:amd64 libqt5test5:amd64 libqt5webchannel5:amd64 libqt5webengine-data libqt5webenginecore5:amd64 libqt5webenginewidgets5:amd64 libqt5webkit5:amd64 libqt5widgets5:amd64 libqt5x11extras5:amd64  libqt5xml5:amd64 libqt5xmlpatterns5:amd64 qt5-default:amd64 qt5-doc qt5-gtk-platformtheme:amd64 qt5-qmake:amd64 qt5-qmltooling-plugins:amd64


## Known bugs and issues

* __4K (High DPI Displays)__ If you encounter troubles with high DPI displays on Windows, please to see this link: https://bugreports.qt.io/browse/QTBUG-53022


## Updating your build

You need to update the project:

      git pull --rebase
      git submodule sync && git submodule update --init --recursive

Then simply re-building using the appropriate tool corresponding to your platform (make, Visual Studio...) should be sufficient to update the build (after having updated the source code via git).
However if the compilation fails, you may need to rebuild everything from scratch (Delete all files in your build-desktop folder).

Then you re-build as usual.

## Contributing

### Languages

Linphone is getting a full internationalization support, using Transifex platform.
If you want you can contribute at: https://www.transifex.com/belledonne-communications/linphone-desktop/languages/

### Feedback or bug reporting

Launch the application with `--verbose` parameter to get full logs and send it with your request.

On some OS (like Fedora 22 and later), they disable Qt debug output by default. To get full output, you need to create `~/.config/QtProject/qtlogging.ini` and add :

        [Rules]
        *.debug=true
        qt.*.debug=false
