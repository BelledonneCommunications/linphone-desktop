# -*- rpm-spec -*-

%define _prefix    @CMAKE_INSTALL_PREFIX@
%define pkg_prefix @BC_PACKAGE_NAME_PREFIX@

%define _datarootdir       %{_prefix}/share
%define _datadir           %{_datarootdir}
%define _docdir            %{_datadir}/doc

%define build_number @PROJECT_VERSION_BUILD@
%if %{build_number}
%define build_number_ext -%{build_number}
%endif

Name:           @CPACK_PACKAGE_NAME@
Version:        @PROJECT_VERSION@
Release:        %{build_number}%{?dist}
Summary:        A free (libre) SIP video-phone.

Group:          Communications/Telephony
License:        GPL
URL:            https://www.linphone.org
Source0:        %{name}-%{version}%{?build_number_ext}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-buildroot

Requires:       %{pkg_prefix}bctoolbox
Requires:       %{pkg_prefix}belcard
Requires:       %{pkg_prefix}liblinphone
Requires:       %{pkg_prefix}mediastreamer
Requires:       %{pkg_prefix}minizip
Requires:       %{pkg_prefix}qt

%description
A free (libre) SIP video-phone.

%if 0%{?rhel} && 0%{?rhel} <= 7
%global cmake_name cmake3
%define ctest_name ctest3
%else
%global cmake_name cmake
%define ctest_name ctest
%endif

%define custom_debug_package %{!?_enable_debug_packages:%debug_package}%{?_enable_debug_package:%{nil}}
%custom_debug_package

%prep
%setup -n %{name}-%{version}%{?build_number_ext}

%build
%{expand:%%%cmake_name} . -DCMAKE_BUILD_TYPE=@CMAKE_BUILD_TYPE@ -DCMAKE_PREFIX_PATH:PATH=%{_prefix} @RPM_ALL_CMAKE_OPTIONS@
make %{?_smp_mflags}

%install
make install DESTDIR=%{buildroot}

%clean
rm -rf $RPM_BUILD_ROOT

%post
  /sbin/ldconfig
  for i in 16 22 24 32 64 128
  do
    xdg-icon-resource install --novendor --mode system --theme hicolor --context apps --size $i %{_datarootdir}/icons/hicolor/${i}x${i}/apps/linphone.png linphone
  done
  xdg-desktop-menu install --novendor --mode system %{_datarootdir}/applications/linphone.desktop

%postun
  xdg-desktop-menu uninstall --mode system linphone.desktop
  for i in 16 22 24 32 64 128
  do
    xdg-icon-resource uninstall --mode system --theme hicolor --context apps --size $i linphone
  done
  /sbin/ldconfig

%files
%defattr(-,root,root,-)
%doc LICENSE.txt CHANGELOG.md README.md
%{_bindir}/
%{_datadir}/

%changelog

* Tue Nov 27 2018 ronan.abhamon <ronan.abhamon@belledonne-communications.com>
- Do not set CMAKE_INSTALL_LIBDIR and never with _libdir!

* Thu Mar 15 2018 ronan.abhamon <ronan.abhamon@belledonne-communications.com>
- Initial RPM release.
