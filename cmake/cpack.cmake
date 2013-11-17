#
#    Copyright (C) 2013 Venom authors and contributors
#
#    This file is part of Venom.
#
#    Venom is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Venom is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Venom.  If not, see <http://www.gnu.org/licenses/>.
#

IF(WIN32)
  FILE(GLOB WIN32LIBS "${CMAKE_CURRENT_BINARY_DIR}/win32libs/*.dll")
  IF(NOT EXISTS "${CMAKE_CURRENT_BINARY_DIR}/libsodium_license.txt")
    FILE(
      DOWNLOAD 
        "https://raw.github.com/jedisct1/libsodium/master/LICENSE"
        "${CMAKE_CURRENT_BINARY_DIR}/libsodium_license.txt"
      EXPECTED_MD5
        979a30c71c9a8d0174c10898ac3e5595
    )
  ENDIF()
  SET(CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS ${WIN32LIBS})
  INCLUDE(InstallRequiredSystemLibraries)
  INSTALL(
    FILES 
      "${CMAKE_CURRENT_BINARY_DIR}/libsodium_license.txt"
    DESTINATION
      "${COMMON_DATA_DIR}/licenses/libsodium"
    RENAME
      LICENSE
  )
ENDIF(WIN32)

# Basic settings
SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "GTK+/Vala GUI for Tox")
SET(CPACK_PACKAGE_EXECUTABLES    "venom;Venom")
SET(CPACK_PACKAGE_INSTALL_DIRECTORY   "Venom")
SET(CPACK_PACKAGE_NAME           "Venom")
SET(CPACK_PACKAGE_VERSION_MAJOR  "${VENOM_VERSION_MAJOR}")
SET(CPACK_PACKAGE_VERSION_MINOR  "${VENOM_VERSION_MINOR}")
SET(CPACK_PACKAGE_VERSION_PATCH  "${VENOM_VERSION_PATCH}")
SET(CPACK_SOURCE_IGNORE_FILES /build/;\\\\.gitignore;.*~;\\\\.git;CMakeFiles;Makefile;cmake_install\\\\.cmake)
SET(CPACK_SOURCE_STRIP_FILES TRUE)
SET(CPACK_STRIP_FILES TRUE)

# Advanced
SET(CPACK_RESOURCE_FILE_LICENSE  "${CMAKE_SOURCE_DIR}/COPYING")
SET(CPACK_PACKAGE_VERSION        "${VENOM_VERSION}")

# nsis
#TODO set correct path depending on architecture
#SET(CPACK_NSIS_INSTALL_ROOT "$PROGRAMFILES64")
# There is a bug in NSI that does not handle full unix paths properly. Make
# sure there is at least one set of four (4) backslashes.
#SET(CPACK_NSIS_MUI_ICON "${CMAKE_SOURCE_DIR}/misc/\\\\venom.ico")
#SET(CPACK_NSIS_MUI_UNIICON "${CMAKE_SOURCE_DIR}/misc/\\\\venom.ico")
SET(CPACK_PACKAGE_ICON "${CMAKE_SOURCE_DIR}/icons/48x48\\\\venom.png")
#SET(CPACK_NSIS_INSTALLED_ICON_NAME "")
SET(CPACK_NSIS_DISPLAY_NAME "Venom")
#SET(CPACK_NSIS_HELP_LINK "http:\\\\\\\\www.my-project-home-page.org")
#SET(CPACK_NSIS_URL_INFO_ABOUT "http:\\\\\\\\www.my-personal-home-page.com")
#SET(CPACK_NSIS_CONTACT "me@my-personal-home-page.com")
SET(CPACK_NSIS_MUI_FINISHPAGE_RUN "venom.exe")

# .deb
SET(CPACK_DEBIAN_PACKAGE_DEPENDS "libgtk-3-0 (>= 3.2), libgee-0.8-2 (>= 0.8), libtoxcore (>= 0.0)")
INCLUDE(CPack)
