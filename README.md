# Linphone Desktop

![screenshot](readme_screen.png)

Linphone is a free VoIP and video softphone based on the SIP protocol.

## Getting started

Here are the general instructions to build linphone for desktop. The specific instructions for each build platform is described just below.

1. Install some build tools: `CMake`, `Python` `Java` (build dependency for `belle-sip`) and `Qt5` (_5.9 or newer_). `C++11` support is required!
2. It's necessary to set the environment variable `Qt5_DIR` to point to the path containing the cmake folders of Qt5. Example:

        Qt5_DIR="~/Qt/5.9/gcc_64/lib/cmake"

3. The `PATH` environment variable must point to the Qt5 directory `bin`. Example:

        PATH="~/Qt/5.9/gcc_64/bin/:$PATH"

4. Prepare the build by running the `prepare.py` script.
5. Build the project using the appropriate build tool (`make`, `ninja`, `Xcode`, `Visual Studio (2013 or 2015 version)`).

### Specific instructions for Mac OS X

1. Install Xcode from the Apple store. Run it at least once to allow it to install its tools.

2. Install homebrew by following the instructions here https://brew.sh/

3. Install dependencies:

        brew install cmake qt git

4. Clone the gituhub repository, cd into that folder, clean the project configuration and then build the compile scripts:

        ./prepare.py -c && ./prepare.py -DENABLE_PACKAGING=ON -p

5. Build the project in a terminal with:

        make
        
### Specific instructions for Linux/Unix

1. Prepare the build in a terminal by running the following command in the current directory:

        ./prepare.py

2. Build the project in a terminal with:

        make

### Specific instructions for the Windows platform

1. Ensure that you have downloaded the `Qt msvc2015 version` (32-bit). (64-bit version is not supported at this moment by Linphone Desktop.) `MinGW` must be installed too.

2. Define the `Qt5_DIR` and `PATH` environment variable to the Qt5 installation path:

        Qt5_DIR="C:\Qt\5.9\msvc2015\lib\cmake"
        PATH="C:\Qt\5.9\msvc2015\bin;%PATH%"

3. Open a Windows command line (cmd.exe) in the current directory and run:

        python prepare.py -G "Visual Studio 14 2015"

4. Open the generated Visual Studio solution `Project.sln.lnk` and build it. Check if the `Release` option is selected in Visual Studio. (With `Win32`!)

## Known bugs and issues

* __4K (High DPI Displays)__ If you encounter troubles with high DPI displays on Windows, please to see this link: https://bugreports.qt.io/browse/QTBUG-53022

## Customizing your build

Some options can be given during the `prepare.py` step to customize the build. The basic usage of the `prepare.py` script is:

        ./prepare.py [options]

Here are the main options you can use.

### Building with debug symbols

Building with debug symbols is necessary if you want to be able to debug the application using some tools like GDB or the Visual Studio debugger. To do so, pass the `--debug` option to `prepare.py`:

        ./prepare.py --debug [other options]

### Generating an installation package (on Windows and Mac OS X platforms)

You might want to generate an installation package to ease the distribution of the application. To add the package generation step to the build just run:

        ./prepare.py --package [other options]

### Activate the build of all codecs

        ./prepare.py --all-codecs

### Using more advanced options

The `prepare.py` script is wrapper around CMake. Therefore you can give any CMake option to the `prepare.py` script.
To get a list of the options you can pass, you can run:

        ./prepare.py --list-cmake-variables

The options that enable you to configure what will be built are the ones beginning with `ENABLE_`. So for example, you might want to build linphone without the opus codec support. To do so use:

        ./prepare.py -DENABLE_OPUS=NO

## Updating your build

Updating from git requires an additional command to ensure any new submodules are added and updated:

        git submodule update --init --recursive
        git pull

Simply re-building using the appropriate tool corresponding to your platform (make, Visual Studio...) should be sufficient.
However if the compilation fails, you may need to rebuild everything from scratch using:

        ./prepare.py -c && ./prepare.py [options]

Then build as usual.

## Contributing

### Languages

Linphone is getting a full internationalization support, using Transifex platform.
If you want you can contribute at: https://www.transifex.com/belledonne-communications/linphone-desktop/languages/

## License

GPLv2 © [Linphone](https://linphone.org)
