# - Try to find LibDJBCns

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

# Once done this will define
#  DJBDNS_FOUND - System has djbdns
#  DJBDNS_INCLUDE_DIRS - The djbdns include directories
#  DJBDNS_LIBRARIES - The libraries needed to use djbdns

IF(DJBDNS_LIBRARIES AND DJBDNS_INCLUDE_DIRS)
  # in cache already
  SET(DJBDNS_FOUND TRUE)
ELSE(DJBDNS_LIBRARIES AND DJBDNS_INCLUDE_DIRS)
  SET(DJBDNS_DIRECTORY "" CACHE PATH "Set a directory to search for DJBDNS libraries and headers")
  FIND_PATH(DJBDNS_LIBRARY_DIR
    NAMES dns.a
    PATHS
      /usr/lib
      /usr/local/lib
      ${DJBDNS_DIRECTORY}
  )
  FIND_PATH(DJBDNS_INCLUDE_DIR
    NAMES dns.h
    PATHS
      /usr/include
      /usr/local/include
      ${DJBDNS_DIRECTORY}
  )
  FIND_FILE(DJBDNS_IOPAUSE_OBJECT
    NAMES iopause.o
    PATHS ${DJBDNS_LIBRARY_DIR}
  )
  FIND_LIBRARY(DJBDNS_DNS_LIBRARY
    NAMES dns.a
    PATHS ${DJBDNS_LIBRARY_DIR}
  )
  FIND_LIBRARY(DJBDNS_ENV_LIBRARY
    NAMES env.a
    PATHS ${DJBDNS_LIBRARY_DIR}
  )
  FIND_LIBRARY(DJBDNS_LIBTAI_LIBRARY
    NAMES libtai.a
    PATHS ${DJBDNS_LIBRARY_DIR}
  )
  FIND_LIBRARY(DJBDNS_ALLOC_LIBRARY
    NAMES alloc.a
    PATHS ${DJBDNS_LIBRARY_DIR}
  )
  FIND_LIBRARY(DJBDNS_BUFFER_LIBRARY
    NAMES buffer.a
    PATHS ${DJBDNS_LIBRARY_DIR}
  )
  FIND_LIBRARY(DJBDNS_UNIX_LIBRARY
    NAMES unix.a
    PATHS ${DJBDNS_LIBRARY_DIR}
  )
  FIND_LIBRARY(DJBDNS_BYTE_LIBRARY
    NAMES byte.a
    PATHS ${DJBDNS_LIBRARY_DIR}
  )
  SET(DJBDNS_LIBRARIES
    ${DJBDNS_IOPAUSE_OBJECT}
    ${DJBDNS_DNS_LIBRARY}
    ${DJBDNS_ENV_LIBRARY}
    ${DJBDNS_LIBTAI_LIBRARY}
    ${DJBDNS_ALLOC_LIBRARY}
    ${DJBDNS_BUFFER_LIBRARY}
    ${DJBDNS_UNIX_LIBRARY}
    ${DJBDNS_BYTE_LIBRARY}
    ${DJBDNS_SOCKET_LIBRARY}
  )
  SET(DJBDNS_INCLUDE_DIRS ${DJBDNS_INCLUDE_DIR})
  SET(DJBDNS_CFLAGS "-I${DJBDNS_INCLUDE_DIR}")
  MARK_AS_ADVANCED(DJBDNS_INCLUDE_DIRS DJBDNS_LIBRARIES)
ENDIF(DJBDNS_LIBRARIES AND DJBDNS_INCLUDE_DIRS)
