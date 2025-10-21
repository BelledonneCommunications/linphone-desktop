import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic

import Linphone
import UtilsCpp
import SettingsCpp
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

ColumnLayout{
	id: mainItem
	property AccountGui account: null
	property string topText: account ? account.core.displayName : ""
	property string bottomText: account ? SettingsCpp.hideSipAddresses ? UtilsCpp.getUsername(account.core.identityAddress) : account.core.identityAddress : ""
	spacing: 0
	width: topTextItem.implicitWidth
	Text {
		id: topTextItem
		Layout.fillHeight: true
		Layout.fillWidth: true
		verticalAlignment: (bottomTextItem.visible?Text.AlignBottom:Text.AlignVCenter)
		visible: text != ""
        font.weight: Typography.p1.weight
        font.pixelSize: Typography.p1.pixelSize
		color: DefaultStyle.main2_700
		text: mainItem.topText
		width: mainItem.width
		wrapMode: Text.WrapAnywhere
		maximumLineCount: 1
	}
	Text {
		id: bottomTextItem
		Layout.fillHeight: true
		Layout.fillWidth: true
		verticalAlignment: (topTextItem.visible?Text.AlignTop:Text.AlignVCenter)
		visible: text != ''
        font.weight: Utils.getSizeWithScreenRatio(300)
        font.pixelSize: Utils.getSizeWithScreenRatio(12)
		color: DefaultStyle.main2_400
		text: mainItem.bottomText
		maximumLineCount: 1
		wrapMode: Text.WrapAnywhere
	}
}
