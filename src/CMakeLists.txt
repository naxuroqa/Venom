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

FIND_PACKAGE(Vala "0.17.0" REQUIRED)
FIND_PACKAGE(PkgConfig REQUIRED)

SET(TARGET_GLIB 2.32)

PKG_CHECK_MODULES(GTK  REQUIRED gtk+-3.0>=3.2)
PKG_CHECK_MODULES(GEE  REQUIRED gee-0.8>=0.8)
PKG_CHECK_MODULES(GIO  REQUIRED gio-2.0>=${TARGET_GLIB})
PKG_CHECK_MODULES(GLIB REQUIRED glib-2.0>=${TARGET_GLIB})
PKG_CHECK_MODULES(TOX  REQUIRED libtoxcore>=0.0)

ADD_DEFINITIONS( ${GTK_CFLAGS} ${GTK_CFLAGS_OTHER}
                 ${GEE_CFLAGS} ${GEE_CFLAGS_OTHER}
                 ${GIO_CFLAGS} ${GIO_CFLAGS_OTHER}
                 ${GLIB_CFLAGS} ${GLIB_CFLAGS_OTHER}
                 ${TOX_CFLAGS} ${TOX_CFLAGS_OTHER}
)

CONFIGURE_FILE ("${PROJECT_SOURCE_DIR}/src/config.h.in"
                "${PROJECT_BINARY_DIR}/src/config.h" )

SET( VENOM_SRC
  core/Client.vala
  core/Contact.vala
  core/DhtServer.vala
  core/GroupChat.vala
  core/Message.vala
  core/ResourceFactory.vala
  core/SettingsProvider.vala
  core/Tools.vala
  core/ToxSession.vala
  ui/AddContactDialog.vala
  ui/AboutDialog.vala
  ui/ConversationTreeView.vala
  ui/ConversationWindow.vala
  ui/ContactListWindow.vala
  ui/ContactListTreeView.vala
  ui/ContactListCellRenderer.vala
  ui/PreferencesWindow.vala
  ui/UserInfoWindow.vala
  Main.vala
)

MESSAGE("${GLIB_VERSION}.${GLIB_VERSION_MINOR}")

VALA_PRECOMPILE( VALA_C_VENOM
    ${VENOM_SRC}
  PACKAGES
    gee-0.8
    gtk+-3.0
    glib-2.0
    gio-2.0
    tox-1.0
    config
  OPTIONS
    --target-glib=${GLIB_VERSION}
    --thread
    --vapidir=${CMAKE_SOURCE_DIR}/src/vapi
  CUSTOM_VAPIS
  GENERATE_VAPI
  GENERATE_HEADER
)

VALA_PRECOMPILE( VALA_C_TEST
    testing/ToxVapiTest.vala
    core/Tools.vala
  PACKAGES
    gio-2.0
    tox-1.0
  OPTIONS
    --debug
    --vapidir=${CMAKE_SOURCE_DIR}/src/vapi
  CUSTOM_VAPIS
  GENERATE_VAPI
  GENERATE_HEADER
)

VALA_PRECOMPILE( VALA_C_GROUPTEST
    testing/GroupTest.vala
    core/Tools.vala
  PACKAGES
    gee-0.8
    gio-2.0
    tox-1.0
  OPTIONS
    --debug
    --vapidir=${CMAKE_SOURCE_DIR}/src/vapi
  CUSTOM_VAPIS
  GENERATE_VAPI
  GENERATE_HEADER
)

ADD_EXECUTABLE( venom
  ${VALA_C_VENOM}
)

ADD_EXECUTABLE( vapi_test
  ${VALA_C_TEST}
)

ADD_EXECUTABLE( grouptest
  ${VALA_C_GROUPTEST}
)

TARGET_LINK_LIBRARIES( venom
                       ${GTK_LIBRARIES}
                       ${GEE_LIBRARIES}
                       ${GIO_LIBRARIES}
                       ${GLIB_LIBRARIES}
                       ${TOX_LIBRARIES}
)

TARGET_LINK_LIBRARIES( vapi_test
                       ${GIO_LIBRARIES}
                       ${TOX_LIBRARIES}
)

TARGET_LINK_LIBRARIES( grouptest
                       ${GEE_LIBRARIES}
                       ${GIO_LIBRARIES}
                       ${TOX_LIBRARIES}
)

INSTALL(TARGETS venom RUNTIME DESTINATION ${VENOM_BIN_INSTALL_DESTINATION})

# vim:set ts=2 sw=2 et:
