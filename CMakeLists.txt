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

CMAKE_MINIMUM_REQUIRED(VERSION 2.8.7)
PROJECT(Venom C)

LIST(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/modules)

SET(VENOM_VERSION_MAJOR 0)
SET(VENOM_VERSION_MINOR 2)
SET(VENOM_VERSION_PATCH 0)
SET(VENOM_VERSION_TWEAK 0)
SET(VENOM_VERSION
  ${VENOM_VERSION_MAJOR}.${VENOM_VERSION_MINOR}.${VENOM_VERSION_PATCH})
SET(VENOM_COPYRIGHT_NOTICE "Copyright © 2013-2014 Venom authors and contributors")
SET(VENOM_SHORT_DESCRIPTION "GTK+/Vala GUI for Tox")
SET(VENOM_WEBSITE "https://github.com/naxuroqa/Venom")

IF(WIN32)
  SET(CMAKE_INSTALL_SYSTEM_RUNTIME_DESTINATION .)
ELSE(WIN32)
  SET(CMAKE_INSTALL_SYSTEM_RUNTIME_DESTINATION bin)
ENDIF(WIN32)

IF(BUILD_STATIC_EXECUTABLES)
  set(CMAKE_EXE_LINKER_FLAGS -static)
  set(CMAKE_FIND_LIBRARY_SUFFIXES .a .dll.a)
  set(CMAKE_EXE_LINK_DYNAMIC_C_FLAGS)       # remove -Wl,-Bdynamic
  set(CMAKE_SHARED_LIBRARY_C_FLAGS)         # remove -fPIC
  set(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS)    # remove -rdynamic
ENDIF(BUILD_STATIC_EXECUTABLES) 

SET(COMMON_DATA_DIR share)
SET(VENOM_THEME_INSTALL_DESTINATION "${COMMON_DATA_DIR}/venom/theme")

ADD_SUBDIRECTORY(misc)
ADD_SUBDIRECTORY(icons)
ADD_SUBDIRECTORY(theme)

ADD_SUBDIRECTORY(src)

INCLUDE(${CMAKE_SOURCE_DIR}/cmake/cpack.cmake)

# vim:set ts=2 sw=2 et:
