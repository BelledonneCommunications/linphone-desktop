################################################################################
#  toolchain-windows-store-x64.cmake
#  Copyright (c) 2021-2023 Belledonne Communications SARL.
# 
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
# 
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
# 
#  You should have received a copy of the GNU General Public License
#  along with this program. If not, see <http://www.gnu.org/licenses/>.
#
################################################################################

# set(CMAKE_SYSTEM_PROCESSOR "x86_64")
set(MICROSOFT_STORE_LINK_PATHS "\$(WindowsSDK_LibraryPath_x64);\$(NETFXKitsDir)Lib\\um\\x64;\$(VC_LibraryPath_VC_x64_store);\$(VC_ReferencesPath_ATL_x64);\$(VC_LibraryPath_VC_x64);\$(VC_LibraryPath_x64);\$(VC_VS_LibraryPath_VC_VS_x64);\$(LibraryPath);\$(VC_LibraryPath_VC_x64_store)\\references")

include("${CMAKE_CURRENT_LIST_DIR}/toolchain-windows-store-common.cmake")
