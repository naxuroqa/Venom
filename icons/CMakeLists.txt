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

INCLUDE(Rsvg OPTIONAL)

SET(PIXMAP_SIZES
  16
  32
  48
  64
  128
  256
)

SET( VENOM_SVG
  scalable/venom.svg
)

IF(RSVG_CONVERT_EXECUTABLE AND GENERATE_PIXMAPS)
  RSVG_CONVERT( VENOM_GENERATED_PIXMAPS
    SOURCE
      ${VENOM_SVG}
  )
  ADD_CUSTOM_TARGET( generate_pixmaps
    ALL
    COMMENT
      "Generating pixmaps from svg"
    DEPENDS
      ${VENOM_GENERATED_PIXMAPS}
  )
ENDIF(RSVG_CONVERT_EXECUTABLE AND GENERATE_PIXMAPS)

FOREACH(pixmap_size ${PIXMAP_SIZES})
  INSTALL(FILES ${pixmap_size}x${pixmap_size}/venom.png 
    DESTINATION 
      "${COMMON_DATA_DIR}/icons/hicolor/${pixmap_size}x${pixmap_size}/apps"
  )
ENDFOREACH(pixmap_size ${PIXMAP_SIZES})

INSTALL(FILES ${VENOM_SVG} 
  DESTINATION "${COMMON_DATA_DIR}/icons/hicolor/scalable/apps")
INSTALL(FILES 256x256/venom.png 
  DESTINATION "${COMMON_DATA_DIR}/pixmaps")
