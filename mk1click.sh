#!/bin/bash

BUILD=build
APP=Pharo-1.4-nightly-OneClick.app
ZIP=`basename $APP .app`.zip
JENKINS=https://ci.lille.inria.fr/pharo/view

if [ -e $BUILD ]; then
  echo "Build directory '$BUILD' exists.  Please remove before trying again."
  exit 1
fi

rm -f cog-unix.zip cog-mac.zip Pharo-1.4.zip

echo "Fetch Linux Cog VM"
curl -o cog-unix.zip  $JENKINS/VM/job/Cog-Unix/lastSuccessfulBuild/artifact/Cog.zip
echo "Fetch MacOS Cog VM"
curl -o cog-mac.zip   $JENKINS/VM/job/Cog-Mac-Cocoa-blessed/lastSuccessfulBuild/artifact/CogVM.zip
echo "Fetch Pharo 1.4 image"
curl -o Pharo-1.4.zip $JENKINS/Pharo%201.4/job/Pharo%201.4/lastSuccessfulBuild/artifact/Pharo-1.4.zip

echo "Unpack and rearrange files"
unzip -q -d $BUILD cog-mac.zip
mv $BUILD/CogVM.app $BUILD/$APP
mv $BUILD/$APP/Contents/MacOS/CogVM $BUILD/$APP/Contents/MacOS/pharo
unzip -q -d $BUILD/$APP/Contents/Linux cog-unix.zip
mv $BUILD/$APP/Contents/Linux/CogVM $BUILD/$APP/Contents/Linux/pharo
unzip -q -j -d $BUILD/$APP/Contents/Resources Pharo-1.4.zip
mv $BUILD/$APP/Contents/Resources/Pharo-1.4.image $BUILD/$APP/Contents/Resources/pharo.image
mv $BUILD/$APP/Contents/Resources/Pharo-1.4.changes $BUILD/$APP/Contents/Resources/pharo.changes

echo "Additional files"
cp misc/Info.plist $BUILD/$APP/Contents
cp misc/PkgInfo $BUILD/$APP/Contents
cp misc/Pharo.icns $BUILD/$APP/Contents/Resources
cp misc/SqueakImage.icns $BUILD/$APP/Contents/Resources
cp misc/pharo.sh $BUILD/$APP
cp misc/readme.txt $BUILD/$APP

echo "Zip up results"
( rm -f $ZIP; cd $BUILD; zip -q -r ../$ZIP $APP )

echo "Clean up"
rm -f cog-unix.zip cog-mac.zip Pharo-1.4.zip
rm -rf $BUILD

echo "Done"
ls -l $ZIP
