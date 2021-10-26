# -*- rpm-spec -*-

%define _qt5_version 5.12
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

#Notes for Qt 5.12 and above
#qt-xcb includes libxcb-* but libxcb
#qt-xkbcommon cannot be used anymore
#-xkbcommon enables xkb support using system libs

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
  -dbus \
  -feature-dbus \
  -feature-accessibility \
  -qt-freetype \
  -qt-harfbuzz \
  -qt-libjpeg \
  -qt-libpng \
  -qt-pcre \
  -qt-xcb \
  -xkbcommon \
  -system-freetype \
  -feature-freetype -fontconfig \
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

make -j12

%install
find . \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i 's/#!\/usr\/bin\/python/#!\/usr\/bin\/python3/g'
make install INSTALL_ROOT=%{buildroot} -j12

# Some files got ambiguous python shebangs, we fix them to avoid install errors
# Because in centos8 shebangs like #!/usr/bin/python are FORBIDDEN (see https://fedoraproject.org/wiki/Changes/Make_ambiguous_python_shebangs_error)

%files
%defattr(-,root,root,-)
%license LICENSE.LGPL* LICENSE.FDL
%{_qt5_archdatadir}/phrasebooks/*.qph
%{_qt5_archdatadir}/qml/
%{_qt5_bindir}/
%{_qt5_docdir}/global/
%{_qt5_libdir}/libQt5*.so*
%{_qt5_plugindir}/*/*.so*
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
