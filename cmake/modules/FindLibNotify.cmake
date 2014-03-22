# Find the Libnotify libraries

# This module will find the libnotify library, and do some
# sanity checking (making sure things compile, version checking,
# dependancy checking, etc). Libnotify requires the GTK Library (GTK2 or GTK3) and glib Library (GLIB2)

# This requires cmake => 2.8 to work correctly

# @Author: Jacob "HACKhalo2" Litewski
# @Version: 1.0
# @Email: hackhalo2@precipicegames.com

## DEFINE LIBNOTIFY_INCLUDE_DIR Where to find the libnotify headers
## DEFINE LIBNOTIFY_LIBRARIES The libraries that are needed to use libnotify
## DEFINE LIBNOTIFY_FOUND The Boolean for checking to see if libnotify was found on the system
## DEFINE LIBNOTIFY_LIBRARY Where to find the libnotify libraries

# Firstly, check to make sure that libnotify (or it's dependants) isn't already in CMake's cache

## Check for GTK2 or GTK3
if((GTK2_INCLUDE_DIR AND GTK2_LIBRARIES) OR (GTK3_INCLUDE_DIR AND GTK3_LIBRARIES))
    set(GTK_IN_CACHE TRUE) # GTK in cache
endif((GTK2_INCLUDE_DIR AND GTK2_LIBRARIES) OR (GTK3_INCLUDE_DIR AND GTK3_LIBRARIES))

## Check for GLIB2
if(GLIB2_INCLUDE_DIR AND GLIB2_LIBRARIES)
    set(GLIB_IN_CACHE TRUE) # GLIB in cache
endif(GLIB2_INCLUDE_DIR AND GLIB2_LIBRARIES)

## Check for Libnotify
if(LIBNOTIFY_INCLUDE_DIR AND LIBNOTIFY_LIBRARIES)
    set(LIBNOTIFY_IN_CACHE TRUE) # Libnotify in cache
endif(LIBNOTIFY_INCLUDE_DIR AND LIBNOTIFY_LIBRARIES)

## Set up the paths
find_path(LIBNOTIFY_INCLUDE_DIR notify.h
    PATHS
    HINTS ${PKG_LIBNOTIFY_INCLUDE_DIRS}
    PATH_SUFFIXES libnotify
)

find_library(LIBNOTIFY_LIBRARIES notify
    NAMES ${LIBNOTIFY_NAMES}
)

## Is Libnotify found?
if(LIBNOTIFY_INCLUDE_DIR AND LIBNOTIFY_LIBRARIES)
    set(LIBNOTIFY_LIBRARIES ${LIBNOTIFY_LIBRARY})
    set(LIBNOTIFY_FOUND TRUE)
else(LIBNOTIFY_INCLUDE_DIR AND LIBNOTIFY_LIBRARIES)
    set(LIBNOTIFY_FOUND FALSE)
endif(LIBNOTIFY_INCLUDE_DIR AND LIBNOTIFY_LIBRARIES)

## If found, run some sanity checks, else fail out
if(LIBNOTIFY_FOUND)
    include(CheckCSourceCompiles)
    if(NOT GLIB_IN_CACHE)
        find_package(GLIB2 REQUIRED)
    endif(NOT GLIB_IN_CACHE)
    if(NOT GTK_IN_CACHE)
        find_package(GTK3 QUIET)
        if(NOT GTK3_FOUND)
            find_package(GTK2 REQUIRED) #Require at least GTK2
        endif(NOT GTK3_FOUND)
    endif(NOT GTK_IN_CACHE)
    
    #Correctly set up GTK dependancies
    if(GTK3_FOUND)
        set(CMAKE_REQUIRED_INCLUDES
            ${LIBNOTIFY_INCLUDE_DIR}
            ${GLIB2_INCLUDE_DIR}
            ${GTK3_INCLUDE_DIRS}
        )
        set(CMAKE_REQUIRED_LIBRARIES
            ${LIBNOTIFY_LIBRARIES}
            ${GLIB2_LIBRARIES}
            ${GTK3_LIBRARIES}
        )
    else(GTK3_FOUND)
        set(CMAKE_REQUIRED_INCLUDES
            ${LIBNOTIFY_INCLUDE_DIR}
            ${GLIB2_INCLUDE_DIR}
            ${GTK2_INCLUDE_DIRS}
        )
        set(CMAKE_REQUIRED_LIBRARIES
            ${LIBNOTIFY_LIBRARIES}
            ${GLIB2_LIBRARIES}
            ${GTK2_LIBRARIES}
        )
    endif(GTK3_FOUND)
    
    check_c_source_compiles("
#include <libnotify/notify.h>
int main() {
notify_notification_new('nothing', 'nothing', 'nothing', 'nothing');
}
" LIBNOTIFY_VERSION_04)
    
    check_c_source_compiles("
#include <libnotify/notify.h>
int main() {
notify_notification_new('nothing', 'nothing', 'nothing');
}
" LIBNOTIFY_VERSION_07)
    
    # Sanity check the above commands
    if(NOT LIBNOTIFY_VERSION_07 AND NOT LIBNOTIFY_VERSION_04)
        message(FATAL_ERROR "Version checking failed! Aborting")
    endif(NOT LIBNOTIFY_VERSION_07 AND NOT LIBNOTIFY_VERSION_04)
    
    # Reset these
    set(CMAKE_REQUIRED_INCLUDES)
    set(CMAKE_REQUIRED_LIBRARIES)
    
    if(NOT LIBNOTIFY_FIND_QUIETLY)
        if(LIBNOTIFY_VERSION_07)
            message(STATUS "Found libnotify: '${LIBNOTIFY_LIBRARIES}' and header in '${LIBNOTIFY_INCLUDE_DIR}' version => 0.7")
        endif(LIBNOTIFY_VERSION_07)
        if(LIBNOTIFY_VERSION_04)
            message(STATUS "Found libnotify: '${LIBNOTIFY_LIBRARIES}' and header in '${LIBNOTIFY_INCLUDE_DIR}' version => 0.4")
        endif(LIBNOTIFY_VERSION_04)
    endif(NOT LIBNOTIFY_FIND_QUIETLY)
else(LIBNOTIFY_FOUND) # Libnotify was not found
    if(LIBNOTIFY_FOUND_REQUIRED) # Check to see if it's required
        MESSAGE(FATAL_ERROR "Could not find libnotify library")
    endif(LIBNOTIFY_FOUND_REQUIRED)
endif(LIBNOTIFY_FOUND)

## Finally, set the caches (Idea taken from quassel2go)
set(LIBNOTIFY_INCLUDE_DIR ${LIBNOTIFY_INCLUDE_DIR} CACHE INTERNAL "The libnotify include directory")
set(LIBNOTIFY_LIBRARIES ${LIBNOTIFY_LIBRARIES} CACHE INTERNAL "The libnotify libraries")
set(HAVE_LIBNOTIFY_0_4 ${HAVE_LIBNOTIFY_0_4} CACHE INTERNAL "Whether the version of libnotify is >= 0.4")
set(HAVE_LIBNOTIFY_0_7 ${HAVE_LIBNOTIFY_0_7} CACHE INTERNAL "Whether the version of libnotify is >= 0.7")

mark_as_advanced(LIBNOTIFY_INCLUDE_DIR LIBNOTIFY_LIBRARIES)