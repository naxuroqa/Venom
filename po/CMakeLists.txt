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

SET(TRANSLATIONS
  de
  fr
  it
  pl
  ru
)

IF (XGETTEXT_FOUND)
  GETTEXT_CREATE_TRANSLATIONS(${GETTEXT_PACKAGE}.pot ALL ${TRANSLATIONS} COMMENT "Creating translations.")
ELSE ()
  message(STATUS "xgettext not found")
ENDIF()

