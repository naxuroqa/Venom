#
#    Copyright (C) 2013-2014 Venom authors and contributors
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

LIST(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

SET(VENOM_VERSION_MAJOR 0)
SET(VENOM_VERSION_MINOR 2)
SET(VENOM_VERSION_PATCH 0)
SET(VENOM_VERSION_RELEASE "" CACHE STRING "")
SET(VENOM_VERSION
  ${VENOM_VERSION_MAJOR}.${VENOM_VERSION_MINOR}.${VENOM_VERSION_PATCH}${VENOM_VERSION_RELEASE})
SET(VENOM_COPYRIGHT_NOTICE "Copyright © 2013-2014 Venom authors and contributors")
SET(VENOM_SHORT_DESCRIPTION "GTK+/Vala GUI for Tox")
SET(VENOM_WEBSITE "https://github.com/naxuroqa/Venom")

MESSAGE("Venom version ${VENOM_VERSION}")

OPTION( FORCE_32BIT "Set to ON to force 32bit build" OFF )
OPTION( BUILD_STATIC_EXECUTABLES "" OFF)
OPTION( ENABLE_QR_ENCODE "Set to ON to enable QR codes" OFF )
OPTION( ENABLE_DJBDNS "Set to ON to use djbdns to resolve tox dns ids (mandatory for glib <= 2.32)" OFF )
OPTION( ENABLE_LIBNOTIFY "Set to ON to enable notifications with libnotify" OFF )

#check architecture
IF(CMAKE_SIZEOF_VOID_P EQUAL 8)
  IF(FORCE_32BIT)
    MESSAGE("32 bit architecture forced.")
    SET(ARCHITECTURE 32)
    SET_PROPERTY(GLOBAL PROPERTY FIND_LIBRARY_USE_LIB64_PATHS 0)
    SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -m32")
  ELSE(FORCE_32BIT)
    MESSAGE("64 bit architecture detected.")
    SET(ARCHITECTURE 64)
  ENDIF(FORCE_32BIT)
ELSE(CMAKE_SIZEOF_VOID_P EQUAL 8)
  MESSAGE("32 bit architecture detected.")
  SET(ARCHITECTURE 32)
ENDIF(CMAKE_SIZEOF_VOID_P EQUAL 8)

#put binary in root on windows
IF(WIN32)
  SET(CMAKE_INSTALL_SYSTEM_RUNTIME_DESTINATION .)
ELSE(WIN32)
  SET(CMAKE_INSTALL_SYSTEM_RUNTIME_DESTINATION bin)
ENDIF(WIN32)

SET(COMMON_DATA_DIR share)

#Check for Vala
find_package(Vala REQUIRED)

#i18n
INCLUDE(Gettext)
SET(GETTEXT_PACKAGE "Venom")
#FIXME make this work for portable installations at runtime
SET(GETTEXT_PATH "${CMAKE_INSTALL_PREFIX}/${COMMON_DATA_DIR}/locale")

ADD_SUBDIRECTORY(misc)
ADD_SUBDIRECTORY(icons)
ADD_SUBDIRECTORY(theme)
ADD_SUBDIRECTORY(sounds)
ADD_SUBDIRECTORY(src)
ADD_SUBDIRECTORY(po)

INCLUDE(CPackDefines)

# vim:set ts=2 sw=2 et:
