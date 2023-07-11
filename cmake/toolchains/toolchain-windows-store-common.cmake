############################################################################
# toolchain-windows-store-common.cmake
# Copyright (c) 2021-2023 Belledonne Communications SARL.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
############################################################################

set(CMAKE_C_STANDARD_LIBRARIES "WindowsApp.lib ${CMAKE_C_STANDARD_LIBRARIES}")
set(CMAKE_CXX_STANDARD_LIBRARIES "WindowsApp.lib ${CMAKE_CXX_STANDARD_LIBRARIES}")

set(CMAKE_EXE_LINKER_FLAGS_INIT "/APPCONTAINER")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "/APPCONTAINER")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "/APPCONTAINER")


add_compile_definitions("ENABLE_MICROSOFT_STORE_APP" "_WIN32_WINNT=0x0A00")


link_directories(BEFORE ${MICROSOFT_STORE_LINK_PATHS})
