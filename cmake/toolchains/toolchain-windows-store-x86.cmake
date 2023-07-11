################################################################################
#  toolchain-windows-store-x86.cmake
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

# set(CMAKE_SYSTEM_PROCESSOR "x86")
set(MICROSOFT_STORE_LINK_PATHS "\$(WindowsSDK_LibraryPath_x86);\$(NETFXKitsDir)Lib\\um\\x86;\$(VC_LibraryPath_VC_x86_store);\$(VC_ReferencesPath_ATL_x86);\$(VC_LibraryPath_VC_x86);\$(VC_LibraryPath_x86);\$(VC_VS_LibraryPath_VC_VS_x86);\$(LibraryPath);\$(VC_LibraryPath_VC_x86_store)\\references")

include("${CMAKE_CURRENT_LIST_DIR}/toolchain-windows-store-common.cmake")
