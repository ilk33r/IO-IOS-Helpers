#!/bin/sh

#  Build.sh
#  ioshelpers
#
#  Created by ilker özcan on 04/02/16.
#  Copyright © 2016 ilkerozcan. All rights reserved.

#!/bin/bash
buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$INFOPLIST_FILE")
buildNumber=$(($buildNumber + 1))
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "$INFOPLIST_FILE"
version=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$INFOPLIST_FILE")

/usr/libexec/PlistBuddy -c "Set PreferenceSpecifiers:1:DefaultValue $version ($buildNumber)" "${SRCROOT}/Settings.bundle/Root.plist"