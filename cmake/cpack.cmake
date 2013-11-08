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

IF(WIN32 AND NOT UNIX)
  # There is a bug in NSI that does not handle full unix paths properly. Make
  # sure there is at least one set of four (4) backslashes.
  SET(CPACK_PACKAGE_ICON "${CMAKE_SOURCE_DIR}/pixmaps\\\\venom.png")
  #SET(CPACK_NSIS_INSTALLED_ICON_NAME "bin\\\\Venom.exe")
  SET(CPACK_NSIS_DISPLAY_NAME "${CPACK_PACKAGE_INSTALL_DIRECTORY} GTK+/Vala GUI for Tox")
  #SET(CPACK_NSIS_HELP_LINK "http:\\\\\\\\www.my-project-home-page.org")
  #SET(CPACK_NSIS_URL_INFO_ABOUT "http:\\\\\\\\www.my-personal-home-page.com")
  #SET(CPACK_NSIS_CONTACT "me@my-personal-home-page.com")
  SET(CPACK_NSIS_MODIFY_PATH ON)
ELSE(WIN32 AND NOT UNIX)
  SET(CPACK_STRIP_FILES "bin/venom")
  SET(CPACK_SOURCE_STRIP_FILES "")
ENDIF(WIN32 AND NOT UNIX)

INCLUDE(InstallRequiredSystemLibraries)
SET(CPACK_PACKAGE_NAME           "venom")
SET(CPACK_RESOURCE_FILE_LICENSE  "${CMAKE_SOURCE_DIR}/COPYING")
SET(CPACK_PACKAGE_VERSION_MAJOR  "${VENOM_VERSION_MAJOR}")
SET(CPACK_PACKAGE_VERSION_MINOR  "${VENOM_VERSION_MINOR}")
SET(CPACK_PACKAGE_VERSION_PATCH  "${VENOM_VERSION_PATCH}")
SET(CPACK_PACKAGE_VERSION        "${VENOM_VERSION}")

SET(CPACK_DEBIAN_PACKAGE_DEPENDS "libgtk-3-0 (>= 3.2), libgee-0.8-2 (>= 0.8), libtoxcore (>= 0.0)")
SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "GTK+/Vala GUI for Tox")
INCLUDE(CPack)
