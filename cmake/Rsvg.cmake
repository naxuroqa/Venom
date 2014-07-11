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
FIND_PROGRAM(RSVG_CONVERT_EXECUTABLE NAMES rsvg-convert)
MARK_AS_ADVANCED(RSVG_CONVERT_EXECUTABLE)

INCLUDE(CMakeParseArguments)

FUNCTION(RSVG_CONVERT output)
  CMAKE_PARSE_ARGUMENTS(ARGS "" "DESTINATION;FORMAT;SIZE;SOURCE" ${ARGN})
  IF(ARGS_DESTINATION)
    SET(DESTINATION ${ARGS_DESTINATION})
  ELSE(ARGS_DESTINATION)
    SET(DESTINATION ${CMAKE_CURRENT_SOURCE_DIR})
  ENDIF(ARGS_DESTINATION)
  IF(ARGS_FORMAT)
    SET(FORMAT ${ARGS_FORMAT})
  ELSE(ARGS_FORMAT)
    SET(FORMAT "png")
  ENDIF(ARGS_FORMAT)
  IF(ARGS_SIZE)
    SET(SIZE ${ARGS_SIZE})
  ELSE(ARGS_SIZE)
    SET(SIZE "16" "32" "48" "64" "128" "256")
  ENDIF(ARGS_SIZE)
  
  SET(out_files "")
  
  FOREACH(current_size ${SIZE})
    SET(CURRENT_DESTINATION ${DESTINATION}/${current_size}x${current_size})
    FILE(MAKE_DIRECTORY ${CURRENT_DESTINATION})
    FOREACH(src ${ARGS_SOURCE} ${ARGS_UNPARSED_ARGUMENTS})
      SET(in_file "${CMAKE_CURRENT_SOURCE_DIR}/${src}")
      GET_FILENAME_COMPONENT(WORKING_DIR ${in_file} PATH)
      STRING(REPLACE ".svg" ".${FORMAT}" src ${src})
      GET_FILENAME_COMPONENT(FILENAME ${src} NAME)
      SET(out_file "${CURRENT_DESTINATION}/${FILENAME}")
      LIST(APPEND out_files ${out_file})

      ADD_CUSTOM_COMMAND(
        WORKING_DIRECTORY ${WORKING_DIR}
        OUTPUT ${out_file}
        COMMAND
          ${RSVG_CONVERT_EXECUTABLE}
        ARGS
          ${in_file}
          "-w" ${current_size}
          "-h" ${current_size}
          "-f" ${FORMAT}
          "-o" ${out_file}
        DEPENDS
          ${in_file}
      )
    ENDFOREACH(src ${ARGS_SOURCES} ${ARGS_UNPARSED_ARGUMENTS})
  ENDFOREACH(current_size ${ARGS_SIZE})
  SET(${output} ${out_files} PARENT_SCOPE)
ENDFUNCTION(RSVG_CONVERT)
