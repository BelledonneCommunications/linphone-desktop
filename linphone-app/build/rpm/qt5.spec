# -*- rpm-spec -*-

%define _qt5_version 5.10
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
  -skip wayland \
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
%{_qt5_libdir}/libQt5*.so.5*
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
%{_qt5_headerdir}/Qt*/
%{_qt5_libdir}/*.a
%{_qt5_libdir}/*.la
%{_qt5_libdir}/*.prl
%{_qt5_libdir}/cmake/Qt5*/*.cmake
%{_qt5_libdir}/libQt5*.so
%{_qt5_libdir}/pkgconfig/Qt5*.pc

%changelog
* Wed Dec 12 2018 Ghislain Mary <ghislain.mary@belledonne-communications.com>
- Simplify %files sections

* Wed Mar 21 2018 Ronan Abhamon <ronan.abhamon@belledonne-communications.com>
- Initial RPM
