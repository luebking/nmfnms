#!/bin/sh

# Bespin icon comparator
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

while read line; do
    typ=${line%/*}
    icon=${line#*/}
    if ! grep -E ".*:.*${typ}[^,]*${icon}" alias.txt > /dev/null 2>&1 ; then
        echo $line
    fi
done < full-list.txt
