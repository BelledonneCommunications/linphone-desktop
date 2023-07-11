############################################################################
# toolchain-uwp-common.cmake
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

set(CMAKE_CROSSCOMPILING TRUE)

set(CMAKE_SYSTEM_NAME "WindowsStore")
set(CMAKE_SYSTEM_VERSION "10.0")

set(CMAKE_VS_INCLUDE_INSTALL_TO_DEFAULT_BUILD TRUE)
set(CMAKE_VS_WINRT_BY_DEFAULT TRUE)
