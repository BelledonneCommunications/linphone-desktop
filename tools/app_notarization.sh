#!/bin/bash

#Notarization for Mac. Launch it from the build folder

rm notarize_result.plist

xcrun altool --notarize-app --primary-bundle-id $MACOSX_SIGNING_IDENTIFIER -u "$MACOSX_SIGNING_MAIL" -p "$MACOSX_SIGNING_PASS"  --file OUTPUT/Packages/Linphone*.dmg --output-format xml > "OUTPUT/notarize_result.plist"
request_uuid="$("${PLIST_BUDDY}" -c "Print notarization-upload:RequestUUID"  "/notarize_result.plist")" 
echo "Notarization UUID: ${request_uuid} result: $("${PLIST_BUDDY}" -c "Print success-message"  "notarize_result.plist")"

#Get status from upload
for (( ; ; ))
do
	xcrun altool --notarization-info "${request_uuid}" -u "$MACOSX_SIGNING_MAIL" -p "$MACOSX_SIGNING_PASS" --output-format xml > "notarize_result.plist"
	xcrun_result=$?
	if [ "${xcrun_result}" != "0" ]
	then
		echo "Notarization failed: ${xcrun_result}"
		cat "notarize_result.plist"
		exit 1
	fi
	notarize_status="$("${PLIST_BUDDY}" -c "Print notarization-info:Status"  "notarize_result.plist")"
	if [ "${notarize_status}" == "Notarization in progress" ]
	then
		echo "Waiting for notarization to complete"
		sleep 10
	else
		echo "Notarization status: ${notarize_status}"
		break
	fi
done
log_url="$("${PLIST_BUDDY}" -c "Print notarization-info:LogFileURL"  "notarize_result.plist")"
echo "Notarization log URL: ${log_url}"

if [ "${notarize_status}" != "success" ]
then
	echo "Notarization failed."
	if [ ! -z "${log_url}" ]
	then
		curl "${log_url}"
	fi
	exit 1
fi

echo "Stapling notarization result..."
for (( ; ; ))
do
    xcrun stapler staple -q "OUTPUT/Packages/Linphone*.dmg"
    stapler_result=$?
    if [ "${stapler_result}" = "65" ]
    then
        echo "Waiting for stapling to find record"
        sleep 10
    else
        echo "Stapler status: ${stapler_result}"
        break
    fi
done

spctl --assess --type open --context context:primary-signature -v "OUTPUT/Packages/Linphone*.dmg"
validation_result=$?

if [ "${validation_result}" != 0 ]
then
	echo "Failed to validate image: ${validation_result}"
	curl "${log_url}"
	exit 1
fi
