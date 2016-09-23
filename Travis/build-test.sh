#!/bin/sh
set -e

echo "\x1b[32m -> \x1b[0m Building $1"

if [ "$1" == "ioshelpers" ]; then

	# make sure the output directory exists
	mkdir -p "../IO_IOS_Helpers-Release-Simulator"
	mkdir -p "../IO_IOS_Helpers-Release-Os"
	mkdir -p "../IO_IOS_Helpers-Release-Universal"

	echo "\x1b[32m -> \x1b[0m Building for iPhoneSimulator"
	xcodebuild -project "../ioshelpers.xcodeproj" -scheme $1 -configuration Release -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO BUILD_DIR="./IO_IOS_Helpers-Release-Simulator" BUILD_ROOT="./" clean build > /dev/null

	echo "\x1b[32m -> \x1b[0m Building for iPhoneOS"
	xcodebuild -project "../ioshelpers.xcodeproj" -scheme $1 -configuration Release -sdk iphoneos ONLY_ACTIVE_ARCH=NO BUILD_DIR="./IO_IOS_Helpers-Release-Os" BUILD_ROOT="./" clean build > /dev/null

	# Step 1. Copy the framework structure (from iphoneos build) to the universal folder
	cp -R "../IO_IOS_Helpers-Release-Simulator/Release-iphonesimulator/IO_IOS_Helpers.framework" "../IO_IOS_Helpers-Release-Universal/"

	# Step 2. Create universal binary file using lipo and place the combined executable in the copied framework directory
	echo "\x1b[32m -> \x1b[0m Combining executables"
	lipo -create -output "../IO_IOS_Helpers-Release-Universal/IO_IOS_Helpers.framework/IO_IOS_Helpers" "../IO_IOS_Helpers-Release-Simulator/Release-iphonesimulator/IO_IOS_Helpers.framework/IO_IOS_Helpers" "../IO_IOS_Helpers-Release-Os/Release-iphoneos/IO_IOS_Helpers.framework/IO_IOS_Helpers"

	rm -rf "../IO_IOS_Helpers-Release-Simulator"
	rm -rf "../IO_IOS_Helpers-Release-Os"

	echo "\x1b[32m -> \x1b[0m Build complete"
	exit 0

elif [ "$1" == "ioleftmenu" ]; then

	# make sure the output directory exists
#mkdir -p "../IO_Left_Menu-Release-Simulator"
#mkdir -p "../IO_Left_Menu-Release-Os"
#mkdir -p "../IO_Left_Menu-Release-Universal"

	echo "\x1b[32m -> \x1b[0m Building for iPhoneSimulator"
	xcodebuild -project "../ioshelpers.xcodeproj" -scheme $1 -configuration Release -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO BUILD_DIR="./IO_Left_Menu-Release-Simulator" BUILD_ROOT="./" clean build > /dev/null

#echo "\e[32m-> \e[0m Building for iPhoneOS"
#xcodebuild -project "../ioshelpers.xcodeproj" -scheme $1 -configuration Release -sdk iphoneos ONLY_ACTIVE_ARCH=NO BUILD_DIR="./IO_Left_Menu-Release-Os" BUILD_ROOT="./" clean build > /dev/null

	# Step 1. Copy the framework structure (from iphoneos build) to the universal folder
#cp -R "../IO_Left_Menu-Release-Simulator/Release-iphonesimulator/IO_Left_Menu.framework" "../IO_Left_Menu-Release-Universal/"

	# Step 2. Create universal binary file using lipo and place the combined executable in the copied framework directory
#echo "\e[32m-> \e[0m Combining executables"
#lipo -create -output "../IO_Left_Menu-Release-Universal/IO_Left_Menu.framework/IO_Left_Menu" "../IO_Left_Menu-Release-Simulator/Release-iphonesimulator/IO_Left_Menu.framework/IO_Left_Menu" "../IO_Left_Menu-Release-Os/Release-iphoneos/IO_Left_Menu.framework/IO_Left_Menu"

#rm -rf "../IO_Left_Menu-Release-Simulator"
#rm -rf "../IO_Left_Menu-Release-Os"

#echo "\e[32m-> \e[0m Build complete"
	exit 0

fi