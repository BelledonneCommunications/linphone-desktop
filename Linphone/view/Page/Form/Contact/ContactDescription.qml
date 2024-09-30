import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material

import Linphone
import UtilsCpp
import SettingsCpp

ColumnLayout{
	id: mainItem
	property AccountGui account: null
	property var displayName: account ? UtilsCpp.getDisplayName(account.core.identityAddress) : ""
	property string topText: displayName ? displayName.value : ""
	property string bottomText: account ? SettingsCpp.onlyDisplaySipUriUsername ? UtilsCpp.getUsername(account.core.identityAddress) : account.core.identityAddress : ""
	spacing: 0
	width: topTextItem.implicitWidth
	Text {
		id: topTextItem
		Layout.fillHeight: true
		verticalAlignment: (bottomTextItem.visible?Text.AlignBottom:Text.AlignVCenter)
		visible: text != ''
		font.weight: 400 * DefaultStyle.dp
		font.pixelSize: 14 * DefaultStyle.dp
		color: DefaultStyle.main2_700
		text: mainItem.topText
		width: mainItem.width
		Layout.preferredWidth: mainItem.width
		wrapMode: Text.WrapAnywhere
		maximumLineCount: 1
	}
	Text {
		id: bottomTextItem
		Layout.fillHeight: true
		verticalAlignment: (topTextItem.visible?Text.AlignTop:Text.AlignVCenter)
		visible: text != ''
		font.weight: 300 * DefaultStyle.dp
		font.pixelSize: 12 * DefaultStyle.dp
		color: DefaultStyle.main2_400
		text: mainItem.bottomText
		Layout.preferredWidth: mainItem.width
		maximumLineCount: 1
		wrapMode: Text.WrapAnywhere
	}
}
