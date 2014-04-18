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

VALA_PRECOMPILE( VALA_C_TEST_DHT
    TestDht.vala
    ../core/Tools.vala
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

VALA_PRECOMPILE( VALA_C_TEST_DNS
    TestDns.vala
    "../core/Tools.vala"
    "../core/ToxDns.vala"
  PACKAGES
    gio-2.0
    tox-1.0
    djbdns
  OPTIONS
    --debug
    --vapidir=${CMAKE_SOURCE_DIR}/src/vapi
  CUSTOM_VAPIS
  GENERATE_VAPI
  GENERATE_HEADER
)

VALA_PRECOMPILE( VALA_C_GROUP_BOT
    GroupBot.vala
    ../core/Tools.vala
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


ADD_EXECUTABLE( test_dht EXCLUDE_FROM_ALL
  ${VALA_C_TEST_DHT}
)

ADD_EXECUTABLE( test_dns EXCLUDE_FROM_ALL
  ${VALA_C_TEST_DNS}
)

ADD_EXECUTABLE( group_bot EXCLUDE_FROM_ALL
  ${VALA_C_GROUP_BOT}
)

TARGET_LINK_LIBRARIES( test_dht
                       ${TOX_LIBRARIES}
                       ${GIO_LIBRARIES}
)

TARGET_LINK_LIBRARIES( test_dns
                       ${GIO_LIBRARIES}
                       ${DJBDNS_LIBRARIES}
)

TARGET_LINK_LIBRARIES( group_bot
                       ${TOX_LIBRARIES}
                       ${GIO_LIBRARIES}
)
