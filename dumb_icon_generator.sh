#!/bin/sh

# Bespin icon generator
# Copyright 2007-2012 by Thomas Lübking <thomas.luebking@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details
#
# You should have received a copy of the GNU General Public
# License along with this program; if not, write to the
# Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

setname="nmfnms"
sizes="128 64 48 32 22 16"
color=black
halo=white
alpha=80

[ -d "$setname" ] || mkdir "$setname"
for sz in $sizes; do
    echo "${sz}x${sz}"
    echo "------"
    dir=$setname/${sz}x${sz}
    [ -d "$dir" ] || mkdir "$dir"
    for svg in *.svg *.svgz; do
#         links="$(grep ${svg%.svg} $1)"
        if [ ! -e "$svg" ]; then
            continue
        fi
        png="$dir/${svg%.svg*}.png"
        if [ ! -e "$png" ] || [ "$svg" -nt "$png" ]; then
            echo -n "${svg%.svg*} "
            if [ -n "$halo" ]; then
                inkscape -w $((sz-4)) -e ".tmp.png" "$svg" > /dev/null
                if [ -n "$color" ]; then
                    mogrify -fill $color -colorize 100% ".tmp.png"
                fi
                mogrify -bordercolor transparent -border 2x2 ".tmp.png"
                convert -channel RGBA -blur 0x3 ".tmp.png" ".halo.png"
                mogrify -fill $halo -colorize 100% ".halo.png"
                convert ".halo.png" ".tmp.png" -gravity Center -composite "$png"
                rm -f ".halo.png" ".tmp.png"
            else
                inkscape -w $sz -e "$png" "$svg" > /dev/null
                if [ -n "$color" ]; then
                    mogrify -fill $color -colorize 100% "$png"
                fi
            fi
            composite -blend ${alpha}x0 "$png" -size ${sz}x${sz} xc:transparent -matte "$png"
        fi
    done
done
echo ""


