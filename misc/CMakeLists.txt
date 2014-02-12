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
  CONFIGURE_FILE (venom.rc.in venom.rc)
  CONFIGURE_FILE (venom.ico venom.ico COPYONLY)
  SET(VENOM_RESOURCE_FILE ${CMAKE_CURRENT_BINARY_DIR}/venom.rc PARENT_SCOPE)
ELSE(WIN32)
  CONFIGURE_FILE (venom.desktop.in venom.desktop)
  INSTALL(
    FILES
      ${CMAKE_CURRENT_BINARY_DIR}/venom.desktop 
    DESTINATION
      ${COMMON_DATA_DIR}/applications
  )
ENDIF(WIN32)



