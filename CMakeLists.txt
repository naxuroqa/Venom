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

SET(VENOM_MAJOR_VERSION 0)
SET(VENOM_MINOR_VERSION 1)
SET(VENOM_PATCH_VERSION 3)
SET(VENOM_VERSION
  ${VENOM_MAJOR_VERSION}.${VENOM_MINOR_VERSION}.${VENOM_PATCH_VERSION})

LIST(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/vala)
INCLUDE(FindVala)
INCLUDE(${VALA_USE_FILE})

SET(VENOM_PIXMAPS_INSTALL_DESTINATION "share/venom/pixmaps")
SET(VENOM_THEME_INSTALL_DESTINATION "share/venom/theme")
SET(VENOM_UI_INSTALL_DESTINATION "share/venom/ui")
SET(VENOM_BIN_INSTALL_DESTINATION "bin")

SET(VENOM_UI
  ui/add_contact_dialog.glade
  ui/contact_list.glade
  ui/conversation_window.glade
  ui/user_info_window.glade
)
INSTALL(FILES ${VENOM_UI} DESTINATION ${VENOM_UI_INSTALL_DESTINATION})

ADD_SUBDIRECTORY(pixmaps)
ADD_SUBDIRECTORY(src)
ADD_SUBDIRECTORY(theme)

# vim:set ts=2 sw=2 et:
