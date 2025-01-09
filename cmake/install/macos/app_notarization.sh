#!/bin/bash

#Notarization for Mac. Launch it from the build folder

#rm notarize_result.plist
FILES=OUTPUT/macos/Packages/*.dmg
for f in $FILES
do
	linphone_file=$f
done

echo "Uploading $linphone_file file with xcrun notarytool"
xcrun notarytool submit -f json --team-id "$MACOSX_SIGNING_PROVIDER" --password "$MACOSX_SIGNING_PASS" --apple-id "$MACOSX_SIGNING_MAIL" --wait $linphone_file 2>&1 | tee /tmp/notarization_info.json

status=$(jq -r .status </tmp/notarization_info.json)
id=$(jq -r .id </tmp/notarization_info.json)

echo "status=${status} id=${id}"

xcrun notarytool log --team-id "$MACOSX_SIGNING_PROVIDER" --password "$MACOSX_SIGNING_PASS" --apple-id "$MACOSX_SIGNING_MAIL" ${id} -f json >/tmp/notarization_log.json

issues=$(jq -r .issues </tmp/notarization_log.json)
if [ "$issues" != "null" ]; then
	printf "There are issues with the notarization (${issues})\n"
	printf "=== Log output === \n$(cat /tmp/notarization_log.json)\n"
	exit 1
fi

exit 0

