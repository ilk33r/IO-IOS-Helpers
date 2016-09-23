#!/bin/sh
set -e

xctool -project ioshelpers.xcodeproj -sdk iphonesimulator9.3 -scheme $1 build build
xctool -project ioshelpers.xcodeproj -sdk iphonesimulator9.3 -scheme $1 build build

xcodebuild -configuration Debug -target ${TARGET} -sdk ${DEVICE} ${ACTION} RUN_CLANG_STATIC_ANALYZER=NO
xcodebuild -configuration Debug -target ${TARGET} -sdk ${SIMULATOR} ${ACTION} RUN_CLANG_STATIC_ANALYZER=NO
xcodebuild -configuration Release -target ${TARGET} -sdk ${DEVICE} ${ACTION} RUN_CLANG_STATIC_ANALYZER=NO
xcodebuild -configuration Release -target ${TARGET} -sdk ${SIMULATOR} ${ACTION} RUN_CLANG_STATIC_ANALYZER=NO

xcodebuild ioshelpers.xcodeproj -scheme $1 -configuration Release -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO BUILD_DIR="./IO_IOS_Helpers-Release-universal/$1" BUILD_ROOT="${BUILD_ROOT}" clean build > /dev/null


lipo -create -output libJsonKit.a build/Release-iphoneos/libJsonKit.a build/Release-iphonesimulator/libJsonKit.a


exec > /tmp/${PROJECT_NAME}_archive.log 2>&1

UNIVERSAL_OUTPUTFOLDER=${BUILD_DIR}/${CONFIGURATION}-universal

if [ "true" == ${ALREADYINVOKED:-false} ]
then
echo "RECURSION: Detected, stopping"
else
export ALREADYINVOKED="true"

# make sure the output directory exists
mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"

echo "Building for iPhoneSimulator"
xcodebuild -workspace "${WORKSPACE_PATH}" -scheme "${SCHEME_NAME}" -configuration ${CONFIGURATION} -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}" clean build > /dev/null

# Step 1. Copy the framework structure (from iphoneos build) to the universal folder
echo "Copying to output folder"
cp -R "${ARCHIVE_PRODUCTS_PATH}${INSTALL_PATH}/${FULL_PRODUCT_NAME}" "${UNIVERSAL_OUTPUTFOLDER}/"

# Step 2. Create universal binary file using lipo and place the combined executable in the copied framework directory
echo "Combining executables"
lipo -create -output "${UNIVERSAL_OUTPUTFOLDER}/${EXECUTABLE_PATH}" "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${EXECUTABLE_PATH}" "${ARCHIVE_PRODUCTS_PATH}${INSTALL_PATH}/${EXECUTABLE_PATH}"

# Step 3. Convenience step to copy the framework to the project's directory
echo "Copying to project dir"
yes | cp -Rf "${UNIVERSAL_OUTPUTFOLDER}/${FULL_PRODUCT_NAME}" "${ARCHIVE_PRODUCTS_PATH}${INSTALL_PATH}"

fi