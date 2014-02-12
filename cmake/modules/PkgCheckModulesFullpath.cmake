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

MACRO(PKG_CHECK_MODULES_FULLPATH MODULE_PREFIX)
  PKG_CHECK_MODULES(${MODULE_PREFIX} ${ARGN})
  IF( BUILD_STATIC_EXECUTABLES )
    SET(LINK_${MODULE_PREFIX}_STATIC TRUE)
    UNSET(LINK_${MODULE_PREFIX}_STATIC CACHE)
  ELSE( BUILD_STATIC_EXECUTABLES )
    OPTION(LINK_${MODULE_PREFIX}_STATIC "Link module ${MODULE_PREFIX} static" FALSE)
  ENDIF( BUILD_STATIC_EXECUTABLES )
  IF( LINK_${MODULE_PREFIX}_STATIC )
    MESSAGE("Linking module ${MODULE_PREFIX} statically.")
    SET(CMAKE_FIND_LIBRARY_SUFFIXES_BAK ${CMAKE_FIND_LIBRARY_SUFFIXES})
    SET(CMAKE_FIND_LIBRARY_SUFFIXES .a)
    FOREACH(i ${${MODULE_PREFIX}_STATIC_LIBRARIES})
      FIND_LIBRARY( ${i}_LIBRARY
                    NAMES ${i}
                    PATHS ${${MODULE_PREFIX}_LIBRARY_DIRS}
                  )
      IF( ${${i}_LIBRARY} MATCHES ${i}_LIBRARY-NOTFOUND)
        MESSAGE("Static library file \"${i}.a\" needed for linking module ${MODULE_PREFIX} not found!")
      ELSE()
        LIST( APPEND ${MODULE_PREFIX}_STATIC_LIBRARIES_FULLPATH ${${i}_LIBRARY} )
      ENDIF()
      UNSET(${i}_LIBRARY CACHE)
    ENDFOREACH(i)
    SET( ${MODULE_PREFIX}_LIBRARIES ${${MODULE_PREFIX}_STATIC_LIBRARIES_FULLPATH} )
    SET(CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_FIND_LIBRARY_SUFFIXES_BAK})
    SET(CMAKE_FIND_LIBRARY_SUFFIXES_BAK)
    SET( ${MODULE_PREFIX}_CFLAGS       ${${MODULE_PREFIX}_STATIC_CFLAGS} )
    SET( ${MODULE_PREFIX}_CFLAGS_OTHER ${${MODULE_PREFIX}_STATIC_CFLAGS_OTHER} )
    MESSAGE("${${MODULE_PREFIX}_LIBRARIES}")
  ELSE()
    FOREACH(i ${${MODULE_PREFIX}_LIBRARIES})
      SET(${i}_LIBRARY ${i}_LIBRARY-NOTFOUND)
      FIND_LIBRARY( ${i}_LIBRARY
                    NAMES ${i}
                    PATHS ${${MODULE_PREFIX}_LIBRARY_DIRS}
                  )
      IF( ${${i}_LIBRARY} MATCHES ${i}_LIBRARY-NOTFOUND)
        MESSAGE( "Library \"${i}\" not found!" )
      ELSE()
        LIST( APPEND ${MODULE_PREFIX}_LIBRARIES_FULLPATH ${${i}_LIBRARY} )
      ENDIF()
      UNSET(${i}_LIBRARY CACHE)
    ENDFOREACH(i)
    SET( ${MODULE_PREFIX}_LIBRARIES ${${MODULE_PREFIX}_LIBRARIES_FULLPATH} )
  ENDIF()
ENDMACRO(PKG_CHECK_MODULES_FULLPATH)
