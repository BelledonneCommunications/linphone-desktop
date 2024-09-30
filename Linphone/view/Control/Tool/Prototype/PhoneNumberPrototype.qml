import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
// Snippet

ListView{
	id: mainItem
	model: PhoneNumberProxy{}
	delegate: Rectangle{
		height: 20
		width: mainItem.width
		RowLayout{
			anchors.fill: parent
			Text{
				text: $modelData.flag
				font.family: DefaultStyle.emojiFont
			}
			Text{
				text: $modelData.country
			}
		}
		MouseArea{
			anchors.fill: parent
			onClicked: console.debug("[ProtoPhoneNumber] Phone number Select: " +$modelData.flag + " / " +$modelData.nationalNumberLength + " / "+$modelData.countryCallingCode + " / " +$modelData.isoCountryCode + " / " +$modelData.internationalCallPrefix + " / " +$modelData.country  )
		}
	}
}

