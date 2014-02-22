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

INCLUDE(FindVala)
INCLUDE(${VALA_USE_FILE})
INCLUDE(GResource)
INCLUDE(PkgCheckModulesFullpath)

FIND_PACKAGE(Vala "0.18.1" REQUIRED)
FIND_PACKAGE(PkgConfig REQUIRED)

SET(TARGET_GLIB 2.32)

PKG_CHECK_MODULES_FULLPATH(GTK    REQUIRED gtk+-3.0>=3.4)
PKG_CHECK_MODULES_FULLPATH(GIO    REQUIRED gio-2.0>=${TARGET_GLIB})
PKG_CHECK_MODULES_FULLPATH(GLIB   REQUIRED glib-2.0>=${TARGET_GLIB})
PKG_CHECK_MODULES_FULLPATH(SQLITE REQUIRED sqlite3>=3.7)
PKG_CHECK_MODULES_FULLPATH(JSON   REQUIRED json-glib-1.0>=0.14)
PKG_CHECK_MODULES_FULLPATH(TOX    REQUIRED libtoxcore>=0.0)

# Workaround for libtoxcore and libsodium not providing info on
# all needed static libraries in their pkg-config files
# see https://github.com/irungentoo/ProjectTox-Core/issues/705
IF(LINK_TOX_STATIC)
  IF(WIN32)
    SET(TOX_LIBRARIES ${TOX_LIBRARIES} m.a ws2_32.a)
  ELSE(WIN32)
    SET(TOX_LIBRARIES ${TOX_LIBRARIES} m.so)
  ENDIF(WIN32)
ENDIF(LINK_TOX_STATIC)
IF(LINK_GTK_STATIC)
  IF(WIN32)
    SET(GTK_LIBRARIES ${GTK_LIBRARIES} usp10.a iphlpapi.a)
  ENDIF(WIN32)
ENDIF(LINK_GTK_STATIC)
IF(LINK_GIO_STATIC)
  IF(WIN32)
    SET(GIO_LIBRARIES ${GIO_LIBRARIES} dnsapi.a iconv.a)
  ENDIF(WIN32)
ENDIF(LINK_GIO_STATIC)

SET(CMAKE_C_FLAGS ${CMAKE_C_FLAGS}
                  ${GTK_CFLAGS}    ${GTK_CFLAGS_OTHER}
                  ${GIO_CFLAGS}    ${GIO_CFLAGS_OTHER}
                  ${GLIB_CFLAGS}   ${GLIB_CFLAGS_OTHER}
                  ${SQLITE_CFLAGS} ${SQLITE_CFLAGS_OTHER}
                  ${JSON_CFLAGS}   ${JSON_CFLAGS_OTHER}
                  ${TOX_CFLAGS}    ${TOX_CFLAGS_OTHER}
)

# since pkg_check_modules returns semicolon
# separated *_c_flags, we have to remove those
STRING(REPLACE ";" " " CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")

CONFIGURE_FILE( config.h.in config.h )

SET( VENOM_SRC
  core/Client.vala
  core/Contact.vala
  core/DhtServer.vala
  core/GroupChat.vala
  core/GroupChatContact.vala
  core/Message.vala
  core/FileTransfer.vala
  core/ResourceFactory.vala
  core/Tools.vala
  core/ToxSession.vala
  core/LocalStorage.vala
  core/VenomSettings.vala
  ui/AddContactDialog.vala
  ui/AboutDialog.vala
  ui/ConversationView.vala
  ui/ConversationWidget.vala
  ui/ChatMessage.vala
  ui/FileTransferChatEntry.vala
  ui/ContactFilter.vala
  ui/ContactListWindow.vala
  ui/ContactListTreeView.vala
  ui/ContactListCellRenderer.vala
  ui/GroupConversationWidget.vala
  ui/TextConversationView.vala
  ui/UserInfoWindow.vala
  ui/UITools.vala
  Main.vala
)

VALA_PRECOMPILE( VALA_C_VENOM
    ${VENOM_SRC}
  PACKAGES
    gtk+-3.0
    glib-2.0
    gio-2.0
    json-glib-1.0
    sqlite3
    tox-1.0
    config
  OPTIONS
    --target-glib=${TARGET_GLIB}
    --thread
    --vapidir=${CMAKE_SOURCE_DIR}/src/vapi
  CUSTOM_VAPIS
  GENERATE_VAPI
  GENERATE_HEADER
)

VALA_PRECOMPILE( VALA_C_TEST_DHT
    testing/TestDht.vala
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

VALA_PRECOMPILE( VALA_C_GROUP_BOT
    testing/GroupBot.vala
    core/Tools.vala
  PACKAGES
    gio-2.0
    tox-1.0
  OPTIONS
    --debug
    --target-glib=${TARGET_GLIB}
    --vapidir=${CMAKE_SOURCE_DIR}/src/vapi
  CUSTOM_VAPIS
  GENERATE_VAPI
  GENERATE_HEADER
)

GLIB_COMPILE_RESOURCES( GLIB_RESOURCES_VENOM
  SOURCE
    ui/venom.gresource.xml
    pixmaps/venom_pixmaps.gresource.xml
)

ADD_EXECUTABLE( venom
  ${VALA_C_VENOM}
  ${GLIB_RESOURCES_VENOM}
  ${VENOM_RESOURCE_FILE}
)

ADD_EXECUTABLE( test_dht EXCLUDE_FROM_ALL
  ${VALA_C_TEST_DHT}
)

ADD_EXECUTABLE( group_bot EXCLUDE_FROM_ALL
  ${VALA_C_GROUP_BOT}
)

TARGET_LINK_LIBRARIES( venom
                       ${TOX_LIBRARIES}
                       ${SQLITE_LIBRARIES}
                       ${GIO_LIBRARIES}
                       ${GLIB_LIBRARIES}
                       ${GTK_LIBRARIES}
                       ${GEE_LIBRARIES}
                       ${JSON_LIBRARIES}
)

TARGET_LINK_LIBRARIES( test_dht
                       ${TOX_LIBRARIES}
                       ${GIO_LIBRARIES}
)

TARGET_LINK_LIBRARIES( group_bot
                       ${TOX_LIBRARIES}
                       ${GIO_LIBRARIES}
)

INSTALL(TARGETS venom RUNTIME DESTINATION ${CMAKE_INSTALL_SYSTEM_RUNTIME_DESTINATION})

# vim:set ts=2 sw=2 et:
