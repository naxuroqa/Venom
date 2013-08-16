CMAKE_MINIMUM_REQUIRED(VERSION 2.6.0)
PROJECT(venom C)

LIST(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/vala)

INCLUDE(FindVala)
INCLUDE(UseVala)

FIND_PACKAGE(Vala REQUIRED)
#ENSURE_VALA_VERSION("0.7.8" MINIMUM)

find_package(PkgConfig)
pkg_check_modules(GTK REQUIRED gtk+-3.0)
add_definitions(${GTK_CFLAGS} ${GTK_CFLAGS_OTHER})
link_libraries(${GTK_LIBRARIES})
link_directories(${GTK_LIBRARY_DIRS})

vala_precompile(VALA_C
  Venom/Main.vala
  Venom/Contact.vala
  Venom/ContactList.vala
PACKAGES
  gtk+-3.0
OPTIONS
CUSTOM_VAPIS
  vapi/tox.vapi
GENERATE_VAPI
GENERATE_HEADER
)

ADD_EXECUTABLE(
	venom
  ${VALA_C}
)

# vim:set ts=2 sw=2 et:
