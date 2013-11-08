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

CMAKE_MINIMUM_REQUIRED(VERSION 2.6.0)
PROJECT(Venom C)

SET(VENOM_VERSION_MAJOR 0)
SET(VENOM_VERSION_MINOR 2)
SET(VENOM_VERSION_PATCH 0)
SET(VENOM_VERSION
  ${VENOM_VERSION_MAJOR}.${VENOM_VERSION_MINOR}.${VENOM_VERSION_PATCH})

LIST(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/vala)
INCLUDE(FindVala)
INCLUDE(${VALA_USE_FILE})

SET(VENOM_PIXMAPS_INSTALL_DESTINATION "share/venom/pixmaps")
SET(VENOM_THEME_INSTALL_DESTINATION "share/venom/theme")
SET(VENOM_UI_INSTALL_DESTINATION "share/venom/ui")
SET(VENOM_BIN_INSTALL_DESTINATION "bin")

ADD_SUBDIRECTORY(pixmaps)
ADD_SUBDIRECTORY(src)
ADD_SUBDIRECTORY(theme)
ADD_SUBDIRECTORY(ui)

INCLUDE(InstallRequiredSystemLibraries)
SET(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/COPYING")
SET(CPACK_PACKAGE_VERSION_MAJOR "${VENOM_VERSION_MAJOR}")
SET(CPACK_PACKAGE_VERSION_MINOR "${VENOM_VERSION_MINOR}")
SET(CPACK_PACKAGE_VERSION_PATCH "${VENOM_VERSION_PATCH}")
INCLUDE(CPack)

# vim:set ts=2 sw=2 et:
