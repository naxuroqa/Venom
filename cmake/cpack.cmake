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
#    CPACK_NSIS_EXTRA_* protocol register and unregister macros from
#    http://hg.pidgin.im/pidgin/main/file/tip/pidgin/win32/nsis/pidgin-installer.nsi
#      Original Author: Herman Bloggs <hermanator12002@yahoo.com>
#      Updated By: Daniel Atallah <daniel_atallah@yahoo.com>

IF(WIN32)
  IF(NOT EXISTS "${CMAKE_CURRENT_BINARY_DIR}/libsodium_license.txt")
    FILE(
      DOWNLOAD 
        "https://raw.github.com/jedisct1/libsodium/master/LICENSE"
        "${CMAKE_CURRENT_BINARY_DIR}/libsodium_license.txt"
    )
  ENDIF()
  INSTALL(
    FILES 
      "${CMAKE_CURRENT_BINARY_DIR}/libsodium_license.txt"
    DESTINATION
      "${COMMON_DATA_DIR}/licenses/libsodium"
    RENAME
      LICENSE
  )
  FILE(GLOB WIN32LIBS "${CMAKE_CURRENT_BINARY_DIR}/win32libs/*.dll")
  SET(CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS ${WIN32LIBS})
  INCLUDE(InstallRequiredSystemLibraries)
ENDIF(WIN32)

# architecure specific stuff
IF(ARCHITECTURE EQUAL 32)
  SET(CPACK_NSIS_INSTALL_ROOT "$PROGRAMFILES")
  SET(CPACK_DEBIAN_PACKAGE_ARCHITECTURE i386)
  SET(CPACK_RPM_PACKAGE_ARCHITECTURE i686)
ELSE(ARCHITECTURE EQUAL 32)
  SET(CPACK_NSIS_INSTALL_ROOT "$PROGRAMFILES64")
  SET(CPACK_DEBIAN_PACKAGE_ARCHITECTURE amd64)
  SET(CPACK_RPM_PACKAGE_ARCHITECTURE x86_64)
ENDIF(ARCHITECTURE EQUAL 32)

# Basic settings
SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${VENOM_SHORT_DESCRIPTION}")
SET(CPACK_PACKAGE_EXECUTABLES         "venom;Venom")
SET(CPACK_PACKAGE_INSTALL_DIRECTORY   "Venom")
SET(CPACK_PACKAGE_NAME                "Venom")
SET(CPACK_PACKAGE_VERSION_MAJOR       "${VENOM_VERSION_MAJOR}")
SET(CPACK_PACKAGE_VERSION_MINOR       "${VENOM_VERSION_MINOR}")
SET(CPACK_PACKAGE_VERSION_PATCH       "${VENOM_VERSION_PATCH}")
SET(CPACK_SOURCE_IGNORE_FILES /build/;\\\\.gitignore;.*~;\\\\.git;CMakeFiles;Makefile;cmake_install\\\\.cmake)
SET(CPACK_SOURCE_STRIP_FILES TRUE)
SET(CPACK_STRIP_FILES TRUE)

# Advanced
SET(CPACK_RESOURCE_FILE_LICENSE    "${CMAKE_SOURCE_DIR}/COPYING")
SET(CPACK_RESOURCE_FILE_README     "${CMAKE_SOURCE_DIR}/README")
SET(CPACK_PACKAGE_VERSION          "${VENOM_VERSION}")
SET(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_SOURCE_DIR}/misc/pkgdesc.txt")
# default: "Humanity", overwrite if needed
#SET(CPACK_PACKAGE_VENDOR           "")

# nsis
# There is a bug in NSI that does not handle full unix paths properly. Make
# sure there is at least one set of four (4) backslashes.
SET(CPACK_NSIS_EXECUTABLES_DIRECTORY ${CMAKE_INSTALL_SYSTEM_RUNTIME_DESTINATION})
SET(CPACK_NSIS_MUI_ICON "${CMAKE_SOURCE_DIR}\\\\misc\\\\venom.ico")
SET(CPACK_NSIS_MUI_UNIICON "${CMAKE_SOURCE_DIR}\\\\misc\\\\venom.ico")
SET(CPACK_PACKAGE_ICON "${CMAKE_SOURCE_DIR}\\\\icons\\\\48x48\\\\venom.png")
SET(CPACK_NSIS_INSTALLED_ICON_NAME "venom.exe")
SET(CPACK_NSIS_DISPLAY_NAME "Venom")
SET(CPACK_NSIS_HELP_LINK "${VENOM_WEBSITE}")
SET(CPACK_NSIS_URL_INFO_ABOUT "${VENOM_WEBSITE}")
SET(CPACK_NSIS_CONTACT "naxuroqa@gmail.com")
SET(CPACK_NSIS_MUI_FINISHPAGE_RUN "venom.exe")
SET(CPACK_NSIS_EXTRA_INSTALL_COMMANDS "
;Register the URI handler
DetailPrint \\\"Registering tox URI Handler\\\"
DeleteRegKey HKCR \\\"tox\\\"
WriteRegStr HKCR \\\"tox\\\" \\\"\\\" \\\"URL:tox\\\"
WriteRegStr HKCR \\\"tox\\\" \\\"URL Protocol\\\" \\\"\\\"
WriteRegStr HKCR \\\"tox\\\\DefaultIcon\\\" \\\"\\\" \\\"$INSTDIR\\\\venom.exe\\\"
WriteRegStr HKCR \\\"tox\\\\shell\\\" \\\"\\\" \\\"\\\"
WriteRegStr HKCR \\\"tox\\\\shell\\\\Open\\\" \\\"\\\" \\\"\\\"
WriteRegStr HKCR \\\"tox\\\\shell\\\\Open\\\\command\\\" \\\"\\\" \\\"$INSTDIR\\\\venom.exe %1\\\"
")
SET(CPACK_NSIS_EXTRA_UNINSTALL_COMMANDS "
;Unregister the URI handler
DetailPrint \\\"Unregistering tox URI Handler\\\"
DeleteRegKey HKCR \\\"tox\\\"
")
# .deb
# libtoxcore ommitted, since we are most likely linking it statically
SET(CPACK_DEBIAN_PACKAGE_DEPENDS  "libgtk-3-0 (>= 3.4.1), libjson-glib-1.0-0 (>= 0.14.2), libsqlite3-0 (>= 3.7.9)")
SET(CPACK_DEBIAN_PACKAGE_PRIORITY "optional")
SET(CPACK_DEBIAN_PACKAGE_SECTION  "web")
SET(CPACK_DEBIAN_PACKAGE_HOMEPAGE "${VENOM_WEBSITE}")

# .rpm
SET(CPACK_RPM_PACKAGE_LICENSE  "GPLv3")
SET(CPACK_RPM_PACKAGE_GROUP    "Applications/Internet")
SET(CPACK_RPM_PACKAGE_REQUIRES "gtk3 >= 3.4.1, json-glib >= 0.14.2, sqlite >= 3.7.9")
# Default: some cpack comment, overwrite if needed
#SET(CPACK_RPM_CHANGELOG_FILE   "")
SET(CPACK_RPM_PACKAGE_RELEASE  1)
SET(CPACK_RPM_PACKAGE_URL      "${VENOM_WEBSITE}")

INCLUDE(CPack)
