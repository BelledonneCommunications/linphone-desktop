Qt6 application.

export PATH=$PATH:~/Qt/6.5.2/gcc_64/bin

optional: export Qt6_DIR=~/Qt/6.5.2/gcc_64/lib/cmake/Qt6

mkdir build \
cd build \
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_BUILD_PARALLEL_LEVEL=10 \
cmake --build .  --target install --parallel 10 \


- Linphone : Application code.
	- model : SDK management that is run on the SDK thread.
	- view: GUI stuff that is run on UI thread.
		- qml: all qml files
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



- Qt install on Linux :
```
sudo apt install qt6-base-dev
```
- Problème à l'exécution : module "QtQuick.\*" is not installed

- Install required packages : 

    - qml-qt6
    - qml6-module-qtquick
    - qml6-module-qtquick-layouts
    - qml6-module-qtqml-workerscript
    - qml6-module-qtquick-controls
    - qml6-module-qtquick-templates

    and any other package missing when running exe\
    with
```
sudo apt update && sudo apt install 
```
