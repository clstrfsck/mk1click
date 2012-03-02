#!/bin/bash

set -e

BUILD=build
JENKINS=https://ci.lille.inria.fr/pharo/job

if [ -e $BUILD ]; then
  echo "Build directory '$BUILD' exists.  Please remove before trying again."
  exit 1
fi

if [ ! -d misc ]; then
  echo "Cant find support directory 'misc'."
  echo "Did you run the script in the right directory?"
  exit 1
fi

function get_buildnum {
    # First argument is job name
    curl -f "$JENKINS/$1/lastSuccessfulBuild/buildNumber"
}

function get_buildfile {
    # First argument is output file, second is job name
    # third is build number and fourth is artifact name
    if [ ! -e "$1" ]; then
	echo "Fetch $1"
	curl -f -o "$1" "$JENKINS/$2/$3/artifact/$4"
    fi
}

echo "Fetch Pharo and VM build numbers"
PBLDNUM=`get_buildnum "Pharo%201.4"`
LBLDNUM=`get_buildnum "Cog-Unix"`
MBLDNUM=`get_buildnum "Cog-Mac-Cocoa"`
#WBLDNUM=`get_buildnum "Cog-Win32"`
WBLDNUM=0

PFILE=Pharo-1.4-${PBLDNUM}.zip
LFILE=cog-linux-${LBLDNUM}.zip
MFILE=cog-macos-${MBLDNUM}.zip
WFILE=cog-win32-${WBLDNUM}.zip

BASENAME=Pharo-1.4-${PBLDNUM}-L${LBLDNUM}-M${MBLDNUM}-W${WBLDNUM}-OneClick
APP=${BASENAME}.app
ZIP=${BASENAME}.zip

if [ -f "$ZIP" ]; then
  echo "$ZIP is already built, exiting."
  exit 0
fi

echo "Building $ZIP using Pharo 1.4 build $PBLDNUM"
echo "Using Linux/MacOS/Win32 Cog VM builds $LBLDNUM/$MBLDNUM/$WBLDNUM"

get_buildfile "$LFILE" "Cog-Unix"	${LBLDNUM} Cog.zip
get_buildfile "$MFILE" "Cog-Mac-Cocoa"	${MBLDNUM} CogVM.zip
get_buildfile "$WFILE" "Cog-Win32"	${WBLDNUM} CogVM.zip

get_buildfile "$PFILE" "Pharo%201.4"	${PBLDNUM} Pharo-1.4.zip

echo "Unpack and rearrange files"
unzip -q -d "$BUILD"				"$MFILE"
mv "$BUILD/CogVM.app" "$BUILD/$APP"
unzip -q -d "$BUILD/$APP/Contents/Linux"	"$LFILE"
unzip -q -d "$BUILD/$APP"			"$WFILE"
unzip -q -j -d "$BUILD/$APP/Contents/Resources"	"$PFILE"

echo "Additional files"
cp misc/Info.plist		"$BUILD/$APP/Contents"
cp misc/PkgInfo			"$BUILD/$APP/Contents"
cp misc/Pharo.icns		"$BUILD/$APP/Contents/Resources"
cp misc/SqueakImage.icns	"$BUILD/$APP/Contents/Resources"
cp misc/pharo.sh		"$BUILD/$APP"
cp misc/pharo.ini		"$BUILD/$APP"
cp misc/readme.txt		"$BUILD/$APP"

echo "Zip up results"
( rm -f "$ZIP"; cd "$BUILD"; zip -q -r "../$ZIP" "$APP" )

echo "Clean up"
rm -rf "$BUILD"

echo "Done"
ls -l "$ZIP"
if [ -x "mk1click-post.sh" ]; then
  ./mk1click-post.sh "$ZIP"
fi
