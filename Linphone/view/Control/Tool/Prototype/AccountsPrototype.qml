import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp 1.0

// Snippet

ListView{
	id: mainItem
	model: AccountProxy {}
	function printObject(o) {
  var out = '';
  for (var p in o) {
    out += p + ': ' + o[p] + '\n';
  }
  if(!o)
    return 'Empty'
  else
    return out;
}

	delegate: Rectangle{
		height: 50
		width: mainItem.width
		RowLayout{
			anchors.fill: parent
			Rectangle{
				Layout.preferredHeight: 50
				Layout.preferredWidth: 50
				//color: '#111111'
				Image{
					id: avatar
					anchors.fill: parent
					source: $modelData.pictureUri
				}
			}
			Text{
				// Store the VariantObject and use value on this object. Do not use value in one line because of looping signals.
				property var displayName: UtilsCpp.getDisplayName($modelData.identityAddress)
				text: displayName ? displayName.value : ""
				onTextChanged: console.log("[ProtoAccounts] Async account displayName: " +$modelData.identityAddress + " => " +text)
			}
			Text{
				text: $modelData.registrationState == LinphoneEnums.RegistrationState.Ok 
						? 'Online'
						: $modelData.registrationState == LinphoneEnums.RegistrationState.Failed
							? 'Error'
							: $modelData.registrationState == LinphoneEnums.RegistrationState.Progress || $modelData.registrationState == LinphoneEnums.RegistrationState.Refreshing
								? 'Connecting'
								: 'Offline'
			
			}
		}
		MouseArea{
			anchors.fill: parent
			property int clickCount : 0
			onClicked: {
				if(++clickCount % 2 == 0)
					$modelData.pictureUri = AppIcons.loginImage;
				else
					$modelData.pictureUri = AppIcons.eyeShow;
					console.log(printObject($modelData))
				console.debug("[ProtoAccounts] Account Select: " +$modelData.contactAddress +" / "+$modelData.identityAddress + " / " +$modelData.pictureUri + " / " +$modelData.registrationState)
			}
		}
	}
}

