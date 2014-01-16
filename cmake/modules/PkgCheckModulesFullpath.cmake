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
  IF(BUILD_STATIC_EXECUTABLES)
    FOREACH(i ${${MODULE_PREFIX}_STATIC_LIBRARIES})
      FIND_LIBRARY( ${i}_LIBRARY
                    NAMES ${i}
                    PATHS ${${MODULE_PREFIX}_LIBRARY_DIRS}
                  )
      IF( ${${i}_LIBRARY} MATCHES ${i}_LIBRARY-NOTFOUND)
        MESSAGE(STATUS "Static library \"${i}\" not found!")
      ELSE()
        LIST( APPEND ${MODULE_PREFIX}_LIBRARIES_FULLPATH ${${i}_LIBRARY} )
      ENDIF()
    ENDFOREACH(i)
  ELSE()
    SET(${MODULE_PREFIX}_LIBRARIES_FULLPATH ${${MODULE_PREFIX}_LIBRARIES})
  ENDIF()
ENDMACRO(PKG_CHECK_MODULES_FULLPATH)
