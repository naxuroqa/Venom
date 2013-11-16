#!/bin/sh
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

venom_svg="../icons/scalable/venom.svg"

rsvg-convert $venom_svg -w 256 -h 256 -o venom_256.png
rsvg-convert $venom_svg -w 48 -h 48 -o venom_48.png
rsvg-convert $venom_svg -w 32 -h 32 -o venom_32.png
rsvg-convert $venom_svg -w 16 -h 16 -o venom_16.png

convert venom_48.png -colors 256 -depth 8 venom_48_8.png
convert venom_32.png -colors 256 -depth 8 venom_32_8.png
convert venom_16.png -colors 256 -depth 8 venom_16_8.png

convert venom_48.png -colors 16 -depth 4 venom_48_4.png
convert venom_32.png -colors 16 -depth 4 venom_32_4.png
convert venom_16.png -colors 16 -depth 4 venom_16_4.png

convert venom_256.png \
        venom_48.png \
        venom_32.png \
        venom_16.png \
        venom_48_8.png \
        venom_32_8.png \
        venom_16_8.png \
        venom_48_4.png \
        venom_32_4.png \
        venom_16_4.png \
        venom.ico
rm venom_*.png
