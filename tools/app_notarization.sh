#!/bin/bash

#Notarization for Mac. Launch it from the build folder

#rm notarize_result.plist
FILES=OUTPUT/Packages/Linphone*.dmg
for f in $FILES
do
    linphone_file=$f
done

echo "Uploading $linphone_file file with xcrun altool"
xcrun altool --notarize-app --primary-bundle-id $MACOSX_SIGNING_IDENTIFIER -u "$MACOSX_SIGNING_MAIL" -p "$MACOSX_SIGNING_PASS" --asc-provider "$MACOSX_SIGNING_PROVIDER" --file $linphone_file --output-format xml > "notarize_result.plist"
echo "dmg processed. Checking UUID"
request_uuid="$("/usr/libexec/PlistBuddy" -c "Print notarization-upload:RequestUUID"  notarize_result.plist)"
echo "Notarization UUID: ${request_uuid}"
#Get status from upload
tryCount=0
for (( ; ; ))
do
    echo "Getting notarization status"
	xcrun altool --notarization-info "${request_uuid}" -u "$MACOSX_SIGNING_MAIL" -p "$MACOSX_SIGNING_PASS" --asc-provider "$MACOSX_SIGNING_PROVIDER" --output-format xml > "notarize_result2.plist"
	xcrun_result=$?
	if [ "${xcrun_result}" != "0" ]
	then
		if [ "${trycount}" -lt "4" ]
		then
			tryCount=$((tryCount+1))
			sleep 60
			continue
		else
			echo "Notarization failed: ${xcrun_result}"
			cat "notarize_result2.plist"
			exit 1
		fi
	fi
	notarize_status="$("/usr/libexec/PlistBuddy" -c "Print notarization-info:Status"  notarize_result2.plist)"
	if [[ "${notarize_status}" == *"in progress"* ]]; then
		echo "Waiting for notarization to complete: ${notarize_status}"
		sleep 20
	else
		echo "Notarization status: ${notarize_status}"
		break
	fi
done
log_url="$("/usr/libexec/PlistBuddy" -c "Print notarization-info:LogFileURL"  notarize_result2.plist)"
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
    xcrun stapler staple -q $linphone_file
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


spctl --assess --type open --context context:primary-signature -v $linphone_file
#validation_result=$?

echo "Validating image : $?"
#if [ "${validation_result}" != 0 ]
#then
#	echo "Failed to validate image: ${validation_result}"
#	curl "${log_url}"
#	exit 1
#fi
exit 0
