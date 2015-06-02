#!/bin/bash

# Bespin icontheme generator
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

SHELL=$_
#if [ ${SHELL##*/} != bash ]; then
#    echo -e "\n\
#============== THIS SCRIPT NEEDS TO RUN AS BASH ============\n\n\
#    Please call either\n\
#    \tbash $0\n\
#    or just\n\
#    \t./$0\n\n\
#============================================================\n\
#(sorry if $SHELL links to /bin/bash \n\t this not catched by this script)
#============================================================\n"
#    exit 1
#fi
## CONFIG ##########################################################################################

basename="nmfnms"
alpha=100
halo="white"

# The color can be empty color="", color= or entirely dropped (commented)
# If given, it MUST be a VALID SYMBOL (black, white, blue, green, red, etc.) or
# A 32bit HEXADECIMAL notation, PREFIXED with a cross ('#')
# Case doesn't matter, but
# It MUST be DOUBLE quoted ("#12345678", the cross is a comment indicator to bash)

# Example:
#color="#2B74C7" # Apples blue

# A halo around the icon, works exactly like the color above
#halo="white"

# The alpha level of the final icon in percent [0-100]
#alpha=77

source ./config

###### ICON THEME MANAGEMENT #######################################################################

sizes="128:64:48:32:22:16"
types="actions:animations:apps:categories:devices:emblems:emotes:intl:mimetypes:places:status"
contexts=("Actions" "Animations" "Applications" "Categories" "Devices" "Emblems" "Emotes" "International" "MimeTypes" "Places" "Status")

####################################################################################################
## END OF CONFIG SECTION ###########################################################################
## DON'T TOUCH BELOW CODE UNLESS YOU KNOW WHAT YOU'RE DOING ########################################
####################################################################################################

setname="$basename"
if [ -n "$color" ]; then
    colorname=${color##*\#}
    colorname=${colorname%%\'*}
    setname="$setname-$colorname"
fi

Jobs=`cat alias.txt | wc -l`
Job=0

# create setnamed dir
IFS=':' # set delimiter
[ -d "$setname" ] || mkdir "$setname"

# create size subdirs
n_sizes=0
for sz in $sizes; do
    ((++n_sizes))
    dir=$setname/${sz}x${sz}
    [ -d "$dir" ] || mkdir "$dir"
    [ -d "$dir/.pool" ] || mkdir "$dir/.pool"
    for typ in $types; do
        [ -d "$dir/$typ" ] || mkdir "$dir/$typ"
    done
done
Jobs=$((Jobs*n_sizes))

# reads alias.txt line by line
while read line; do
    IFS=':' # set delimiter
    # split line into source and destination references
    src=${line%%:*}
    dsts=${line#*:}
    if [ "$src" = "$dsts" ]; then
        Job=$((Job+n_sizes))
        echo -e "\nWARNING: ignoring \"$src\""
        continue
    fi

    svg="$src.svg"; [ -e "$svg" ] || svg="$src.svgz"
    if [ ! -e "$svg" ]; then
        Job=$((Job+n_sizes))
        echo -e "\nERROR: source does not exist: \"$src\""
        continue
    fi
    for sz in $sizes; do
        if ((sz < 48)); then
            os=2;
        else
            os=3;
        fi
        png="$setname/${sz}x${sz}/.pool/$src.png"
        # convert and colorize
        if [ ! -e $png ] || [ $svg -nt $png ]; then
            if [ -n "$halo" ]; then
                inkscape -w $((sz-2*os)) -e ".tmp.png" "$svg" > /dev/null
                if [ -n "$color" ]; then
                    mogrify -fill $color -colorize 100,100,100,0 ".tmp.png"
                fi
                mogrify -bordercolor transparent -border ${os}x${os} ".tmp.png"
                convert -channel RGBA -blur 0x3 ".tmp.png" ".halo.png"
                mogrify -fill $halo -colorize 100,100,100,0 ".halo.png"
                convert ".halo.png" ".tmp.png" -gravity Center -composite "$png"
                rm -f ".halo.png" ".tmp.png"
            else
                inkscape -w $sz -e "$png" "$svg" > /dev/null
                if [ -n "$color" ]; then
                    mogrify -fill $color -colorize 100,100,100,0 "$png"
                fi
            fi
	    if ((alpha < 100)); then
                composite -blend ${alpha}x0 "$png" -size ${sz}x${sz} xc:transparent -matte "$png"
            fi
        fi

        # print progress
        ((++Job))
        IP=$((Job*100/Jobs))
        FP=$((Job*1000/Jobs - 10*IP))
        echo -ne "\r$IP.$FP %  "

        IFS=',' # set delimiter
        for dst in $dsts; do
            # split destination references
            typ=${dst%/*}
            path="$setname/${sz}x${sz}/$typ"
            if [ ! -d "$path" ]; then
                echo -e "\nERROR: invalid type: \"$typ\""
                continue
            fi
            files=${dst##*/}
            IFS=':' # set delimiter
            for f1le in $files; do
                # split multi destination references
                ln -sf "../.pool/$src.png" "$path/$f1le.png"
            done
        done
    done
done < alias.txt

echo -e "\r 100 %"

IFS=""

echo "generate theme file"

echo "
[Icon Theme]
Name=$setname
Comment=question everything!
DisplayDepth=32
Inherits=oxygen

Example=folder

LinkOverlay=link
LockOverlay=lockoverlay
ShareOverlay=share
ZipOverlay=zip

DesktopDefault=48
DesktopSizes=$sizes
ToolbarDefault=22
ToolbarSizes=16,22,32,48
MainToolbarDefault=22
MainToolbarSizes=16,22,32,48
SmallDefault=16
SmallSizes=16,22
PanelDefault=22
PanelSizes=$sizes

" > "$setname/index.theme"

IFS=":"

directories="Directories="
for sz in $sizes; do
for typ in $types; do
    directories="${directories}${sz}x${sz}/$typ,"
done
done

echo "
$directories
" >> "$setname/index.theme"

for sz in $sizes; do
i=0
for typ in $types; do
echo "
[${sz}x${sz}/$typ]
Size=$sz
Context=${contexts[$i]}
Type=Threshold
" >> "$setname/index.theme"
((++i))
done
done
