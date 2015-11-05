Linphone is a free VoIP and video softphone based on the SIP protocol.

![Dialer screenshot](http://www.linphone.org/img/slideshow-computer.png)

# Getting started

Here are the general instructions to build linphone for desktop. The specific instructions for each build platform is described just below.

1. Install some build tools: CMake, Python.
2. Prepare the build by running the prepare.py script.
3. Build the project using the appropriate build tool (make, ninja, Xcode, Visual Studio).

## Specific instructions for the Linux platform

1. Prepare the build in a terminal by running the following command in the current directory:
        ./prepare.py
2. Build the project in a terminal with:
        make

## Specific instructions for the Windows platform

1. Open a Windows command line (cmd.exe) in the current directory and run:
        python prepare.py
2. Open the generated Visual Studio solution (WORK/cmake/Project.sln) and build it.

## Specific instructions for the Mac OS X platform

1. Open iTerm.app in the current directory and run:
        ./prepare.py
2. Build the project with:
        make

# Customizing your build

Some options can be given during the `prepare.py` step to customize the build. The basic usage of the `prepare.py` script is:

        ./prepare.py [options]

Here are the main options you can use.

## Building with debug symbols

Building with debug symbols is necessary if you want to be able to debug the application using some tools like GDB or the Visual Studio debugger. To do so, pass the `--debug` option to `prepare.py`:

        ./prepare.py --debug [other options]

## Generating an installation package (on Windows and Mac OS X platforms)

You might want to generate an installation package to ease the distribution of the application. To add the package generation step to the build just run:

        ./prepare.py --package [other options]

## Activate the build of all codecs

        ./prepare.py --all-codecs

## Using more advanced options

The `prepare.py` script is wrapper around CMake. Therefore you can give any CMake option to the `prepare.py` script.
To get a list of the options you can pass, you can run:

        ./prepare.py --list-cmake-variables

The options that enable you to configure what will be built are the ones beginning with "ENABLE_". So for example, you might want to build linphone without the opus codec support. To do so use:

        ./prepare.py -DENABLE_OPUS=NO

# Updating your build

Simply re-building using the appropriate tool corresponding to your platform (make, Visual Studio...) should be sufficient to update the build (after having updated the source code via git).
However if the compilation fails, you may need to rebuild everything from scratch using:

        ./prepare.py -C && ./prepare.py [options]

Then you re-build as usual.
