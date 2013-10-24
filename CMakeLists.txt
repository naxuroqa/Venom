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
PROJECT(venom C)

LIST(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/vala)

INCLUDE(FindVala)
INCLUDE(${VALA_USE_FILE})

FIND_PACKAGE(Vala "0.17.0" REQUIRED)

FIND_PACKAGE(PkgConfig REQUIRED)

PKG_CHECK_MODULES(GTK REQUIRED gtk+-3.0)
PKG_CHECK_MODULES(GEE REQUIRED gee-0.8)
PKG_CHECK_MODULES(GIO REQUIRED gio-2.0)
PKG_CHECK_MODULES(GLIB REQUIRED glib-2.0)
PKG_CHECK_MODULES(TOX REQUIRED libtoxcore)

ADD_DEFINITIONS( ${GTK_CFLAGS} ${GTK_CFLAGS_OTHER}
                 ${GEE_CFLAGS} ${GEE_CFLAGS_OTHER}
                 ${GIO_CFLAGS} ${GIO_CFLAGS_OTHER}
                 ${GLIB_CFLAGS} ${GLIB_CFLAGS_OTHER}
                 ${TOX_CFLAGS} ${TOX_CFLAGS_OTHER}
)

LINK_DIRECTORIES( ${GTK_LIBRARY_DIRS}
                  ${GEE_LIBRARY_DIRS}
                  ${GIO_LIBRARY_DIRS}
                  ${GLIB_LIBRARY_DIRS}
                  ${TOX_LIBRARY_DIRS}
)

vala_precompile( VALA_C
  src/core/Client.vala
  src/core/Contact.vala
  src/core/DhtServer.vala
  src/core/GroupChat.vala
  src/core/Message.vala
  src/core/ResourceFactory.vala
  src/core/SettingsProvider.vala
  src/core/Tools.vala
  src/core/ToxSession.vala
  src/ui/AddContactDialog.vala
  src/ui/AboutDialog.vala
  src/ui/ConversationTreeView.vala
  src/ui/ConversationWindow.vala
  src/ui/ContactListWindow.vala
  src/ui/ContactListTreeView.vala
  src/ui/ContactListCellRenderer.vala
  src/ui/PreferencesWindow.vala
  src/ui/UserInfoWindow.vala
  src/Main.vala
PACKAGES
  gee-0.8
  gtk+-3.0
  glib-2.0
  gio-2.0
OPTIONS
# Depend on glib 2.32 or get tons of warnings
  --target-glib=2.32
CUSTOM_VAPIS
  src/vapi/tox.vapi
GENERATE_VAPI
GENERATE_HEADER
)

vala_precompile( VALA_C_TEST
  testing/ToxVapiTest.vala
  src/core/Tools.vala
PACKAGES
  gio-2.0
OPTIONS
  --debug
CUSTOM_VAPIS
  src/vapi/tox.vapi
GENERATE_VAPI
GENERATE_HEADER
)

vala_precompile( VALA_C_GROUPTEST
  testing/GroupTest.vala
  src/core/Tools.vala
PACKAGES
  gee-0.8
  gio-2.0
OPTIONS
  --debug
CUSTOM_VAPIS
  src/vapi/tox.vapi
GENERATE_VAPI
GENERATE_HEADER
)

ADD_EXECUTABLE( venom
  ${VALA_C}
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

INSTALL(TARGETS venom RUNTIME DESTINATION bin)

INSTALL(FILES ui/add_contact_dialog.glade DESTINATION share/venom/ui)
INSTALL(FILES ui/contact_list.glade DESTINATION share/venom/ui)
INSTALL(FILES ui/conversation_window.glade DESTINATION share/venom/ui)
INSTALL(FILES ui/user_info_window.glade DESTINATION share/venom/ui)

INSTALL(FILES pixmaps/add.png DESTINATION share/venom/pixmaps)
INSTALL(FILES pixmaps/groupchat.png DESTINATION share/venom/pixmaps)
INSTALL(FILES pixmaps/settings.png DESTINATION share/venom/pixmaps)

INSTALL(FILES pixmaps/default_contact.png DESTINATION share/venom/pixmaps)
INSTALL(FILES pixmaps/default_groupchat.png DESTINATION share/venom/pixmaps)

INSTALL(FILES pixmaps/away.png DESTINATION share/venom/pixmaps)
INSTALL(FILES pixmaps/away_glow.png DESTINATION share/venom/pixmaps)
INSTALL(FILES pixmaps/offline.png DESTINATION share/venom/pixmaps)
INSTALL(FILES pixmaps/offline_glow.png DESTINATION share/venom/pixmaps)
INSTALL(FILES pixmaps/online.png DESTINATION share/venom/pixmaps)
INSTALL(FILES pixmaps/online_glow.png DESTINATION share/venom/pixmaps)

INSTALL(FILES pixmaps/call.png DESTINATION share/venom/pixmaps)
INSTALL(FILES pixmaps/call_video.png DESTINATION share/venom/pixmaps)

INSTALL(FILES pixmaps/venom.png DESTINATION share/venom/pixmaps)
INSTALL(FILES pixmaps/arrow.png DESTINATION share/venom/pixmaps)

INSTALL(FILES theme/default.css DESTINATION share/venom/theme)

# vim:set ts=2 sw=2 et:
