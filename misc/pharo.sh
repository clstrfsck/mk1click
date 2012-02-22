#!/bin/sh

# path
ROOT=`dirname $0`
BASE="$ROOT/Contents/Linux"

# execute
exec "$BASE/CogVM" \
	-plugins "$BASE" \
	-encoding latin1 \
	-vm-display-X11 \
	"$ROOT/Contents/Resources/Pharo-1.4.image"
