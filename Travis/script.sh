#!/bin/sh
set -e

xctool -project ioshelpers.xcodeproj -sdk iphonesimulator9.3 -scheme $1 build build