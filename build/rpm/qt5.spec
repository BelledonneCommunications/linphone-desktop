# -*- rpm-spec -*-

%define _qt5_version 5.10.1
%define _qt5_dir /opt/com.belledonne-communications/linphone

%define _qt5_archdatadir %{_qt5_dir}
%define _qt5_bindir %{_qt5_dir}/bin
%define _qt5_docdir %{_qt5_dir}/doc
%define _qt5_headerdir %{_qt5_dir}/include
%define _qt5_libdir %{_qt5_dir}/lib
%define _qt5_plugindir %{_qt5_dir}/plugins
%define _qt5_translationdir %{_qt5_dir}/translations

Name: linphone-qt
Summary: Qt5
Version: %{_qt5_version}
Release: 1

License: LGPLv2 with exceptions or GPLv3 with exceptions
Url: http://qt-project.org/
Source0: %{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot

%description
Qt is a software toolkit for developing applications.

%package devel
Summary: Development libraries for liblinphone
Group: Development/Libraries
Requires: %{name} = %{version}-%{release}

%description devel
Qt is a software toolkit for developing applications.

%prep
%setup -n %{name}-%{version}

%build
./configure \
  -opensource \
  -confirm-license \
  -release \
  -shared \
  -c++std c++11 \
  -silent \
  -nomake examples \
  -nomake tests \
  -qt-freetype \
  -qt-harfbuzz \
  -qt-libjpeg \
  -qt-libpng \
  -qt-pcre \
  -qt-xcb \
  -qt-xkbcommon \
  -system-zlib \
  -archdatadir %{_qt5_archdatadir} \
  -bindir %{_qt5_bindir} \
  -docdir %{_qt5_docdir} \
  -headerdir %{_qt5_headerdir} \
  -libdir %{_qt5_libdir} \
  -plugindir %{_qt5_plugindir} \
  -prefix %{_qt5_dir} \
  -translationdir %{_qt5_translationdir}

make

%install
make install INSTALL_ROOT=%{buildroot}

%files
%defattr(-,root,root,-)
%license LICENSE.LGPL* LGPL_EXCEPTION.txt LICENSE.FDL
%{_qt5_archdatadir}/phrasebooks/*.qph
%{_qt5_archdatadir}/qml/
%{_qt5_bindir}/
%{_qt5_docdir}/global/
%{_qt5_libdir}/libQt53DAnimation.so.5*
%{_qt5_libdir}/libQt53DCore.so.5*
%{_qt5_libdir}/libQt53DExtras.so.5*
%{_qt5_libdir}/libQt53DInput.so.5*
%{_qt5_libdir}/libQt53DLogic.so.5*
%{_qt5_libdir}/libQt53DQuick.so.5*
%{_qt5_libdir}/libQt53DQuickAnimation.so.5*
%{_qt5_libdir}/libQt53DQuickExtras.so.5*
%{_qt5_libdir}/libQt53DQuickInput.so.5*
%{_qt5_libdir}/libQt53DQuickRender.so.5*
%{_qt5_libdir}/libQt53DQuickScene2D.so.5*
%{_qt5_libdir}/libQt53DRender.so.5*
%{_qt5_libdir}/libQt5Bluetooth.so.5*
%{_qt5_libdir}/libQt5Concurrent.so.5*
%{_qt5_libdir}/libQt5Core.so.5*
%{_qt5_libdir}/libQt5DataVisualization.so.5*
%{_qt5_libdir}/libQt5DBus.so.5*
%{_qt5_libdir}/libQt5Designer.so.5*
%{_qt5_libdir}/libQt5DesignerComponents.so.5*
%{_qt5_libdir}/libQt5EglFSDeviceIntegration.so.5*
%{_qt5_libdir}/libQt5EglFsKmsSupport.so.5*
%{_qt5_libdir}/libQt5Gamepad.so.5*
%{_qt5_libdir}/libQt5Gui.so.5*
%{_qt5_libdir}/libQt5Help.so.5*
%{_qt5_libdir}/libQt5Multimedia.so.5*
%{_qt5_libdir}/libQt5MultimediaQuick.so.5*
%{_qt5_libdir}/libQt5MultimediaWidgets.so.5*
%{_qt5_libdir}/libQt5Network.so.5*
%{_qt5_libdir}/libQt5Nfc.so.5*
%{_qt5_libdir}/libQt5OpenGL.so.5*
%{_qt5_libdir}/libQt5PrintSupport.so.5*
%{_qt5_libdir}/libQt5Qml.so.5*
%{_qt5_libdir}/libQt5Quick.so.5*
%{_qt5_libdir}/libQt5QuickControls2.so.5*
%{_qt5_libdir}/libQt5QuickParticles.so.5*
%{_qt5_libdir}/libQt5QuickTemplates2.so.5*
%{_qt5_libdir}/libQt5QuickTest.so.5*
%{_qt5_libdir}/libQt5QuickWidgets.so.5*
%{_qt5_libdir}/libQt5SerialBus.so.5*
%{_qt5_libdir}/libQt5SerialPort.so.5*
%{_qt5_libdir}/libQt5Sql.so.5*
%{_qt5_libdir}/libQt5Svg.so.5*
%{_qt5_libdir}/libQt5Test.so.5*
%{_qt5_libdir}/libQt5Widgets.so.5*
%{_qt5_libdir}/libQt5XcbQpa.so.5*
%{_qt5_libdir}/libQt5Xml.so.5*
%{_qt5_plugindir}/audio/*.so
%{_qt5_plugindir}/bearer/*.so
%{_qt5_plugindir}/canbus/*.so
%{_qt5_plugindir}/designer/libqquickwidget.so
%{_qt5_plugindir}/egldeviceintegrations/*.so
%{_qt5_plugindir}/gamepads/libevdevgamepad.so
%{_qt5_plugindir}/generic/*.so
%{_qt5_plugindir}/geometryloaders/*.so
%{_qt5_plugindir}/iconengines/libqsvgicon.so
%{_qt5_plugindir}/imageformats/*.so
%{_qt5_plugindir}/mediaservice/libqtmedia_audioengine.so
%{_qt5_plugindir}/platforminputcontexts/*.so
%{_qt5_plugindir}/platforms/*.so
%{_qt5_plugindir}/playlistformats/libqtmultimedia_m3u.so
%{_qt5_plugindir}/qmltooling/*.so
%{_qt5_plugindir}/renderplugins/libscene2d.so
%{_qt5_plugindir}/sceneparsers/*.so
%{_qt5_plugindir}/sqldrivers/*.so
%{_qt5_plugindir}/xcbglintegrations/*.so
%{_qt5_translationdir}/

%files devel
%defattr(-,root,root,-)
%{_qt5_archdatadir}/mkspecs/
%{_qt5_headerdir}/Qt3DAnimation/
%{_qt5_headerdir}/Qt3DCore/
%{_qt5_headerdir}/Qt3DExtras/
%{_qt5_headerdir}/Qt3DInput/
%{_qt5_headerdir}/Qt3DLogic/
%{_qt5_headerdir}/Qt3DQuick/
%{_qt5_headerdir}/Qt3DQuickAnimation/
%{_qt5_headerdir}/Qt3DQuickExtras/
%{_qt5_headerdir}/Qt3DQuickInput/
%{_qt5_headerdir}/Qt3DQuickRender/
%{_qt5_headerdir}/Qt3DQuickScene2D/
%{_qt5_headerdir}/Qt3DRender/
%{_qt5_headerdir}/QtAccessibilitySupport/
%{_qt5_headerdir}/QtBluetooth/
%{_qt5_headerdir}/QtConcurrent/
%{_qt5_headerdir}/QtCore/
%{_qt5_headerdir}/QtDataVisualization/
%{_qt5_headerdir}/QtDBus/
%{_qt5_headerdir}/QtDesigner/
%{_qt5_headerdir}/QtDesignerComponents/
%{_qt5_headerdir}/QtDeviceDiscoverySupport/
%{_qt5_headerdir}/QtEdidSupport/
%{_qt5_headerdir}/QtEglFSDeviceIntegration/
%{_qt5_headerdir}/QtEglSupport/
%{_qt5_headerdir}/QtEventDispatcherSupport/
%{_qt5_headerdir}/QtFbSupport
%{_qt5_headerdir}/QtFontDatabaseSupport/
%{_qt5_headerdir}/QtGamepad/
%{_qt5_headerdir}/QtGlxSupport/
%{_qt5_headerdir}/QtGui/
%{_qt5_headerdir}/QtHelp/
%{_qt5_headerdir}/QtInputSupport/
%{_qt5_headerdir}/QtKmsSupport/
%{_qt5_headerdir}/QtMultimedia/
%{_qt5_headerdir}/QtMultimediaQuick/
%{_qt5_headerdir}/QtMultimediaWidgets/
%{_qt5_headerdir}/QtNetwork/
%{_qt5_headerdir}/QtNfc/
%{_qt5_headerdir}/QtOpenGL/
%{_qt5_headerdir}/QtOpenGLExtensions/
%{_qt5_headerdir}/QtPacketProtocol/
%{_qt5_headerdir}/QtPlatformCompositorSupport/
%{_qt5_headerdir}/QtPlatformHeaders/
%{_qt5_headerdir}/QtPrintSupport/
%{_qt5_headerdir}/QtQml/
%{_qt5_headerdir}/QtQmlDebug/
%{_qt5_headerdir}/QtQuick/
%{_qt5_headerdir}/QtQuickControls2/
%{_qt5_headerdir}/QtQuickParticles/
%{_qt5_headerdir}/QtQuickTemplates2/
%{_qt5_headerdir}/QtQuickTest/
%{_qt5_headerdir}/QtQuickWidgets/
%{_qt5_headerdir}/QtSerialBus/
%{_qt5_headerdir}/QtSerialPort/
%{_qt5_headerdir}/QtServiceSupport/
%{_qt5_headerdir}/QtSql/
%{_qt5_headerdir}/QtSvg/
%{_qt5_headerdir}/QtTest/
%{_qt5_headerdir}/QtThemeSupport/
%{_qt5_headerdir}/QtUiPlugin/
%{_qt5_headerdir}/QtUiTools/
%{_qt5_headerdir}/QtWidgets/
%{_qt5_headerdir}/QtXml/
%{_qt5_libdir}/*.a
%{_qt5_libdir}/*.la
%{_qt5_libdir}/*.prl
%{_qt5_libdir}/cmake/Qt5/*.cmake
%{_qt5_libdir}/cmake/Qt53DAnimation/*.cmake
%{_qt5_libdir}/cmake/Qt53DCore/*.cmake
%{_qt5_libdir}/cmake/Qt53DExtras/*.cmake
%{_qt5_libdir}/cmake/Qt53DInput/*.cmake
%{_qt5_libdir}/cmake/Qt53DLogic/*.cmake
%{_qt5_libdir}/cmake/Qt53DQuick/*.cmake
%{_qt5_libdir}/cmake/Qt53DQuickAnimation/*.cmake
%{_qt5_libdir}/cmake/Qt53DQuickExtras/*.cmake
%{_qt5_libdir}/cmake/Qt53DQuickInput/*.cmake
%{_qt5_libdir}/cmake/Qt53DQuickRender/*.cmake
%{_qt5_libdir}/cmake/Qt53DQuickScene2D/*.cmake
%{_qt5_libdir}/cmake/Qt53DRender/*.cmake
%{_qt5_libdir}/cmake/Qt5Bluetooth/*.cmake
%{_qt5_libdir}/cmake/Qt5Concurrent/*.cmake
%{_qt5_libdir}/cmake/Qt5Core/*.cmake
%{_qt5_libdir}/cmake/Qt5DataVisualization/*.cmake
%{_qt5_libdir}/cmake/Qt5DBus/*.cmake
%{_qt5_libdir}/cmake/Qt5Designer/*.cmake
%{_qt5_libdir}/cmake/Qt5Gamepad/*.cmake
%{_qt5_libdir}/cmake/Qt5Gui/*.cmake
%{_qt5_libdir}/cmake/Qt5Help/*.cmake
%{_qt5_libdir}/cmake/Qt5LinguistTools/*.cmake
%{_qt5_libdir}/cmake/Qt5Multimedia/*.cmake
%{_qt5_libdir}/cmake/Qt5MultimediaWidgets/*.cmake
%{_qt5_libdir}/cmake/Qt5Network/*.cmake
%{_qt5_libdir}/cmake/Qt5Nfc/*.cmake
%{_qt5_libdir}/cmake/Qt5OpenGL/*.cmake
%{_qt5_libdir}/cmake/Qt5OpenGLExtensions/*.cmake
%{_qt5_libdir}/cmake/Qt5PrintSupport/*.cmake
%{_qt5_libdir}/cmake/Qt5Qml/*.cmake
%{_qt5_libdir}/cmake/Qt5Quick/*.cmake
%{_qt5_libdir}/cmake/Qt5QuickControls2/*.cmake
%{_qt5_libdir}/cmake/Qt5QuickTest/*.cmake
%{_qt5_libdir}/cmake/Qt5QuickWidgets/*.cmake
%{_qt5_libdir}/cmake/Qt5SerialBus/*.cmake
%{_qt5_libdir}/cmake/Qt5SerialPort/*.cmake
%{_qt5_libdir}/cmake/Qt5Sql/*.cmake
%{_qt5_libdir}/cmake/Qt5Svg/*.cmake
%{_qt5_libdir}/cmake/Qt5Test/*.cmake
%{_qt5_libdir}/cmake/Qt5UiPlugin/*.cmake
%{_qt5_libdir}/cmake/Qt5UiTools/*.cmake
%{_qt5_libdir}/cmake/Qt5Widgets/*.cmake
%{_qt5_libdir}/cmake/Qt5Xml/*.cmake
%{_qt5_libdir}/libQt53DAnimation.so
%{_qt5_libdir}/libQt53DCore.so
%{_qt5_libdir}/libQt53DExtras.so
%{_qt5_libdir}/libQt53DInput.so
%{_qt5_libdir}/libQt53DLogic.so
%{_qt5_libdir}/libQt53DQuick.so
%{_qt5_libdir}/libQt53DQuickAnimation.so
%{_qt5_libdir}/libQt53DQuickExtras.so
%{_qt5_libdir}/libQt53DQuickInput.so
%{_qt5_libdir}/libQt53DQuickRender.so
%{_qt5_libdir}/libQt53DQuickScene2D.so
%{_qt5_libdir}/libQt53DRender.so
%{_qt5_libdir}/libQt5Bluetooth.so
%{_qt5_libdir}/libQt5Concurrent.so
%{_qt5_libdir}/libQt5Core.so
%{_qt5_libdir}/libQt5DataVisualization.so
%{_qt5_libdir}/libQt5DBus.so
%{_qt5_libdir}/libQt5Designer.so
%{_qt5_libdir}/libQt5DesignerComponents.so
%{_qt5_libdir}/libQt5EglFSDeviceIntegration.so
%{_qt5_libdir}/libQt5EglFsKmsSupport.so
%{_qt5_libdir}/libQt5Gamepad.so
%{_qt5_libdir}/libQt5Gui.so
%{_qt5_libdir}/libQt5Help.so
%{_qt5_libdir}/libQt5Multimedia.so
%{_qt5_libdir}/libQt5MultimediaQuick.so
%{_qt5_libdir}/libQt5MultimediaWidgets.so
%{_qt5_libdir}/libQt5Network.so
%{_qt5_libdir}/libQt5Nfc.so
%{_qt5_libdir}/libQt5OpenGL.so
%{_qt5_libdir}/libQt5PrintSupport.so
%{_qt5_libdir}/libQt5Qml.so
%{_qt5_libdir}/libQt5Quick.so
%{_qt5_libdir}/libQt5QuickControls2.so
%{_qt5_libdir}/libQt5QuickParticles.so
%{_qt5_libdir}/libQt5QuickTemplates2.so
%{_qt5_libdir}/libQt5QuickTest.so
%{_qt5_libdir}/libQt5QuickWidgets.so
%{_qt5_libdir}/libQt5SerialBus.so
%{_qt5_libdir}/libQt5SerialPort.so
%{_qt5_libdir}/libQt5Sql.so
%{_qt5_libdir}/libQt5Svg.so
%{_qt5_libdir}/libQt5Test.so
%{_qt5_libdir}/libQt5Widgets.so
%{_qt5_libdir}/libQt5XcbQpa.so
%{_qt5_libdir}/libQt5Xml.so
%{_qt5_libdir}/pkgconfig/Qt53DAnimation.pc
%{_qt5_libdir}/pkgconfig/Qt53DCore.pc
%{_qt5_libdir}/pkgconfig/Qt53DExtras.pc
%{_qt5_libdir}/pkgconfig/Qt53DInput.pc
%{_qt5_libdir}/pkgconfig/Qt53DLogic.pc
%{_qt5_libdir}/pkgconfig/Qt53DQuick.pc
%{_qt5_libdir}/pkgconfig/Qt53DQuickAnimation.pc
%{_qt5_libdir}/pkgconfig/Qt53DQuickExtras.pc
%{_qt5_libdir}/pkgconfig/Qt53DQuickInput.pc
%{_qt5_libdir}/pkgconfig/Qt53DQuickRender.pc
%{_qt5_libdir}/pkgconfig/Qt53DQuickScene2D.pc
%{_qt5_libdir}/pkgconfig/Qt53DRender.pc
%{_qt5_libdir}/pkgconfig/Qt5Bluetooth.pc
%{_qt5_libdir}/pkgconfig/Qt5Concurrent.pc
%{_qt5_libdir}/pkgconfig/Qt5Core.pc
%{_qt5_libdir}/pkgconfig/Qt5DataVisualization.pc
%{_qt5_libdir}/pkgconfig/Qt5DBus.pc
%{_qt5_libdir}/pkgconfig/Qt5Designer.pc
%{_qt5_libdir}/pkgconfig/Qt5Gamepad.pc
%{_qt5_libdir}/pkgconfig/Qt5Gui.pc
%{_qt5_libdir}/pkgconfig/Qt5Help.pc
%{_qt5_libdir}/pkgconfig/Qt5Multimedia.pc
%{_qt5_libdir}/pkgconfig/Qt5MultimediaWidgets.pc
%{_qt5_libdir}/pkgconfig/Qt5Network.pc
%{_qt5_libdir}/pkgconfig/Qt5Nfc.pc
%{_qt5_libdir}/pkgconfig/Qt5OpenGL.pc
%{_qt5_libdir}/pkgconfig/Qt5OpenGLExtensions.pc
%{_qt5_libdir}/pkgconfig/Qt5PrintSupport.pc
%{_qt5_libdir}/pkgconfig/Qt5Qml.pc
%{_qt5_libdir}/pkgconfig/Qt5Quick.pc
%{_qt5_libdir}/pkgconfig/Qt5QuickControls2.pc
%{_qt5_libdir}/pkgconfig/Qt5QuickTest.pc
%{_qt5_libdir}/pkgconfig/Qt5QuickWidgets.pc
%{_qt5_libdir}/pkgconfig/Qt5SerialBus.pc
%{_qt5_libdir}/pkgconfig/Qt5SerialPort.pc
%{_qt5_libdir}/pkgconfig/Qt5Sql.pc
%{_qt5_libdir}/pkgconfig/Qt5Svg.pc
%{_qt5_libdir}/pkgconfig/Qt5Test.pc
%{_qt5_libdir}/pkgconfig/Qt5UiTools.pc
%{_qt5_libdir}/pkgconfig/Qt5Widgets.pc
%{_qt5_libdir}/pkgconfig/Qt5Xml.pc

%changelog
* Wed Mar 21 2018 Ronan Abhamon <ronan.abhamon@belledonne-communications.com>
- Initial RPM
