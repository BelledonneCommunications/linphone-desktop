import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Linphone
import UtilsCpp

ColumnLayout{
	id: mainItem
	property AccountGui account: null
	property var displayName: account ? UtilsCpp.getDisplayName(account.core.identityAddress) : ''
	property string topText: displayName ? displayName.value : ''
	property string bottomText: account ? account.core.identityAddress : ''
	spacing: 0
	Text{
		id: topTextItem
		Layout.fillWidth: true
		Layout.fillHeight: true
		verticalAlignment: (bottomTextItem.visible?Text.AlignBottom:Text.AlignVCenter)
		visible: text != ''
		font.weight: 400 * DefaultStyle.dp
		font.pixelSize: 14 * DefaultStyle.dp
		color: DefaultStyle.main2_700
		text: mainItem.topText
	}
	Text{
		id: bottomTextItem
		Layout.fillWidth: true
		Layout.fillHeight: true
		verticalAlignment: (topTextItem.visible?Text.AlignTop:Text.AlignVCenter)
		visible: text != ''
		font.weight: 300 * DefaultStyle.dp
		font.pixelSize: 12 * DefaultStyle.dp
		color: DefaultStyle.main2_400
		text: mainItem.bottomText
	}
}
